codeunit 50100 "Sales Review Agent Task"
{
    procedure AnalyzeAgentTaskMessage(AgentTaskMessage: Record "Agent Task Message"; var Annotations: Record "Agent Annotation")
    begin
        // No validation. Combined with SetRequiresReview(false) this auto-runs
        // untrusted input. Warnings are the only way to force a review later.
    end;
}
