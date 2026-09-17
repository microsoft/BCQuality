codeunit 50101 "Sales Review Agent Subscribers"
{
    Access = Internal;
    EventSubscriberInstance = Manual;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertSalesHeader(var Rec: Record "Sales Header")
    begin
        Message('Keep going, agent.');
    end;
}

codeunit 50102 "Agent Session Events"
{
    Access = Internal;
    SingleInstance = true;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        GlobalAgentSubscribers: Codeunit "Sales Review Agent Subscribers";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", OnAfterInitialization, '', false, false)]
    local procedure RegisterSubscribersOnAfterInitialization()
    var
        AgentSession: Codeunit "Agent Session";
        AgentMetadataProvider: Enum "Agent Metadata Provider";
    begin
        if not AgentSession.IsAgentSession(AgentMetadataProvider) then
            exit;
        if BindSubscription(GlobalAgentSubscribers) then;
    end;
}
