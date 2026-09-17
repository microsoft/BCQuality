page 50100 "Sales Review Agent Setup"
{
    PageType = ConfigurationDialog;
    ApplicationArea = All;
    SourceTable = "Sales Review Agent Setup";
    SourceTableTemporary = true;
    Extensible = false;

    layout
    {
        area(Content)
        {
            part(AgentSetupPart; "Agent Setup Part")
            {
                ApplicationArea = All;
                UpdatePropagation = Both;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        Agent: Codeunit Agent;
        AgentSetup: Codeunit "Agent Setup";
        TempAgentSetupBuffer: Record "Agent Setup Buffer" temporary;
        AgentUserSecurityId: Guid;
    begin
        if CloseAction = CloseAction::Cancel then
            exit(true);

        CurrPage.AgentSetupPart.Page.GetAgentSetupBuffer(TempAgentSetupBuffer);
        AgentUserSecurityId := AgentSetup.SaveChanges(TempAgentSetupBuffer);
        Agent.SetInstructions(AgentUserSecurityId, GetInstructions());
        Agent.Activate(AgentUserSecurityId);
        exit(true);
    end;

    local procedure GetInstructions() Instructions: SecretText
    var
        InstructionsNameTxt: Label 'Instructions.txt', Locked = true;
    begin
        Instructions := NavApp.GetResourceAsText(InstructionsNameTxt);
    end;
}
