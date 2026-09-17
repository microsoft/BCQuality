codeunit 50100 "Sales Review Agent Factory"
{
    procedure ShowCanCreateAgent(): Boolean
    var
        AgentSystemPermissions: Codeunit "Agent System Permissions";
    begin
        // Hides the type from non-admins in the UI. Does not block Agent.Create.
        exit(AgentSystemPermissions.CurrentUserHasCanManageAllAgentsPermission());
    end;

    procedure CreateIfAllowed()
    var
        Agent: Codeunit Agent;
        AgentSystemPermissions: Codeunit "Agent System Permissions";
        TempAgentAccessControl: Record "Agent Access Control" temporary;
    begin
        if not AgentSystemPermissions.CurrentUserHasCanManageAllAgentsPermission() then
            Error('Only agent administrators can create this agent.');
        Agent.Create(
            Enum::"Agent Metadata Provider"::"Sales Review Agent",
            'SALESREVIEW',
            'Sales Review Agent',
            TempAgentAccessControl);
    end;
}
