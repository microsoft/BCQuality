codeunit 50100 "Sales Review Agent Create"
{
    procedure CreateWithInstructions()
    var
        Agent: Codeunit Agent;
        TempAgentAccessControl: Record "Agent Access Control" temporary;
        AgentUserSecurityId: Guid;
        InstructionsLbl: Label 'You are a sales validation agent. Check credit.', Locked = true;
    begin
        AgentUserSecurityId := Agent.Create(
            Enum::"Agent Metadata Provider"::"Sales Review Agent",
            'SALESREVIEW',
            'Sales Review Agent',
            TempAgentAccessControl);
        // Label/text is not SecretText and is type-wide, not per instance.
        Agent.SetInstructions(AgentUserSecurityId, InstructionsLbl);
        Agent.Activate(AgentUserSecurityId);
    end;
}
