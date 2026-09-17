codeunit 50100 "Sales Review Agent Create"
{
    procedure CreateWithInstructions()
    var
        Agent: Codeunit Agent;
        TempAgentAccessControl: Record "Agent Access Control" temporary;
        AgentUserSecurityId: Guid;
        Instructions: SecretText;
        InstructionsNameTxt: Label 'Instructions.txt', Locked = true;
    begin
        AgentUserSecurityId := Agent.Create(
            Enum::"Agent Metadata Provider"::"Sales Review Agent",
            'SALESREVIEW',
            'Sales Review Agent',
            TempAgentAccessControl);
        Instructions := NavApp.GetResourceAsText(InstructionsNameTxt);
        Agent.SetInstructions(AgentUserSecurityId, Instructions);
        Agent.Activate(AgentUserSecurityId);
    end;
}
