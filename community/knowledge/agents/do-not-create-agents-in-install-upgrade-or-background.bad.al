codeunit 50100 "Sales Review Agent Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        Agent: Codeunit Agent;
        TempAgentAccessControl: Record "Agent Access Control" temporary;
        AgentUserSecurityId: Guid;
    begin
        // Create requires an interactive session. Install is not one.
        AgentUserSecurityId := Agent.Create(
            Enum::"Agent Metadata Provider"::"Sales Review Agent",
            'SALESREVIEW',
            'Sales Review Agent',
            TempAgentAccessControl);
        Agent.Activate(AgentUserSecurityId);
    end;
}
