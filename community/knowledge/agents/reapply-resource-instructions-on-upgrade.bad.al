codeunit 50100 "Sales Review Agent Create"
{
    procedure CreateWithInstructions()
    var
        Agent: Codeunit Agent;
        TempAgentAccessControl: Record "Agent Access Control" temporary;
        AgentUserSecurityId: Guid;
        InstructionsNameTxt: Label 'Instructions.txt', Locked = true;
    begin
        AgentUserSecurityId := Agent.Create(
            Enum::"Agent Metadata Provider"::"Sales Review Agent",
            'SALESREVIEW',
            'Sales Review Agent',
            TempAgentAccessControl);
        // Only new instances get the resource. Upgrades never re-apply it.
        Agent.SetInstructions(AgentUserSecurityId, NavApp.GetResourceAsText(InstructionsNameTxt));
    end;
}
