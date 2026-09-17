codeunit 50110 "Other App Agent Hook"
{
    procedure RenameForeignAgent(AgentUserSecurityId: Guid)
    var
        Agent: Codeunit Agent;
    begin
        // Fails at runtime when the instance was defined in another app.
        Agent.SetDisplayName(AgentUserSecurityId, 'Updated Name');
    end;
}
