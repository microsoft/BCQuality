codeunit 50100 "Sales Review Agent Tasks"
{
    procedure EnqueueFromSalesOrder(SalesHeader: Record "Sales Header"; AgentUserSecurityId: Guid)
    var
        AgentTaskBuilder: Codeunit "Agent Task Builder";
        AgentTaskMessageBuilder: Codeunit "Agent Task Message Builder";
        AgentTask: Record "Agent Task";
    begin
        SalesHeader.TestField("No.");
        AgentTaskMessageBuilder.Initialize('Sales Team', 'Review sales order ' + SalesHeader."No.")
            .SetRequiresReview(false);
        AgentTask := AgentTaskBuilder.Initialize(AgentUserSecurityId, 'Review Sales Order')
            .AddTaskMessage(AgentTaskMessageBuilder)
            .Create();
    end;
}
