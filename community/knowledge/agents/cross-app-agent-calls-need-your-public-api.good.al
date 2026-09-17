codeunit 50110 "Sales Review Agent API"
{
    Access = Public;

    procedure SetDisplayName(AgentUserSecurityId: Guid; NewDisplayName: Text[80])
    var
        Agent: Codeunit Agent;
    begin
        Agent.SetDisplayName(AgentUserSecurityId, NewDisplayName);
    end;

    procedure SetActiveState(AgentUserSecurityId: Guid; ActivateAgent: Boolean)
    var
        Agent: Codeunit Agent;
    begin
        if ActivateAgent then
            Agent.Activate(AgentUserSecurityId)
        else
            Agent.Deactivate(AgentUserSecurityId);
    end;
}
