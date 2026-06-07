// Best practice: each stage is its own Job Queue entry implementing IIntegrationStage,
// dispatched from an extensible enum. Status is the cursor that records the flow's position.
// Stages share no state across runs, so each has its own short lock window and its own retry.

interface IIntegrationStage
{
    procedure Run(var IntegrationMessage: Record "Integration Message");
    procedure NextStatus(): Enum "Integration Status";
}

// Extensible: adding a stage is ONE new codeunit plus ONE enum value, with no orchestrator change.
enum 50210 "Integration Stage" implements IIntegrationStage
{
    Extensible = true;
    value(0; Fetch) { Implementation = IIntegrationStage = "Stage Fetch"; }
    value(1; Transform) { Implementation = IIntegrationStage = "Stage Transform"; }
    value(2; Post) { Implementation = IIntegrationStage = "Stage Post"; }
}

codeunit 50211 "Stage Transform" implements IIntegrationStage
{
    procedure Run(var IntegrationMessage: Record "Integration Message")
    var
        ItemCache: Dictionary of [Code[20], Code[20]];
    begin
        // The cache is local to THIS run. It is created here and gone when Run returns, so it
        // cannot couple this stage to any other. If a lookup were hot enough to want a GLOBAL
        // cache, that would be the signal the split is in the wrong place.
        TransformPayload(IntegrationMessage, ItemCache);
        // Only this stage's work is in scope, so its lock window is short and it commits on its own.
    end;

    procedure NextStatus(): Enum "Integration Status"
    begin
        // Advances the cursor to the next stage. A failure here rolls back ONLY this stage;
        // Fetch stays committed and the flow resumes from Transform, not from the start.
        exit("Integration Status"::Post);
    end;
}

codeunit 50212 "Stage Dispatcher"
{
    TableNo = "Job Queue Entry";

    // Each invocation runs ONE stage as its own Job Queue entry, advances Status, then the next
    // stage runs as a separate entry. No step holds a lock across another step's work.
    procedure RunStage(var IntegrationMessage: Record "Integration Message"; Stage: Enum "Integration Stage")
    var
        StageImpl: Interface IIntegrationStage;
    begin
        StageImpl := Stage;
        StageImpl.Run(IntegrationMessage);

        // Status is the cursor: it records where the flow is up to, so resuming is just reading
        // the next stage. There is no separate per-stage row to reconcile.
        IntegrationMessage.Status := StageImpl.NextStatus();
        IntegrationMessage.Modify(true);
    end;
}
