codeunit 50100 "Sales Review Agent Tasks"
{
    procedure EnqueueFromEmailBody(RawEmailBody: Text; AgentUserSecurityId: Guid)
    var
        AgentTaskBuilder: Codeunit "Agent Task Builder";
        AgentTaskMessageBuilder: Codeunit "Agent Task Message Builder";
        AgentTask: Record "Agent Task";
    begin
        AgentTaskMessageBuilder.Initialize('Internet', RawEmailBody)
            .SetRequiresReview(false);
        AgentTask := AgentTaskBuilder.Initialize(AgentUserSecurityId, 'Process inbound mail')
            .AddTaskMessage(AgentTaskMessageBuilder)
            .Create();
    end;
}
