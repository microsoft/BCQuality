codeunit 50100 "Sales Review Agent Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        Agent: Codeunit Agent;
        UpgradeTag: Codeunit "Upgrade Tag";
        Instructions: SecretText;
        AgentUserSecurityIds: List of [Guid];
        AgentUserSecurityId: Guid;
        TagTxt: Label 'SALESREVIEW-INSTR-2.0.0', Locked = true;
        InstructionsNameTxt: Label 'Instructions.txt', Locked = true;
    begin
        if UpgradeTag.HasUpgradeTag(TagTxt) then
            exit;
        Instructions := NavApp.GetResourceAsText(InstructionsNameTxt);
        AgentUserSecurityIds := GetExistingAgentUserIds();
        foreach AgentUserSecurityId in AgentUserSecurityIds do
            Agent.SetInstructions(AgentUserSecurityId, Instructions);
        UpgradeTag.SetUpgradeTag(TagTxt);
    end;

    local procedure GetExistingAgentUserIds() AgentUserSecurityIds: List of [Guid]
    var
        SalesReviewAgentSetup: Record "Sales Review Agent Setup";
    begin
        if SalesReviewAgentSetup.FindSet() then
            repeat
                AgentUserSecurityIds.Add(SalesReviewAgentSetup."User Security ID");
            until SalesReviewAgentSetup.Next() = 0;
    end;
}
