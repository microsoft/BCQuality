// Demonstration only. Shows the recommended pattern: one guarded registration called on install and on upgrade.

enumextension 50202 "Item Description Capability" extends "Copilot Capability"
{
    value(50202; "Draft Item Description")
    {
        Caption = 'Draft item description';
    }
}

codeunit 50203 "Item Copilot Registration"
{
    Access = Internal;

    procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        LearnMoreUrlTxt: Label 'https://example.com/item-description-copilot', Locked = true;
    begin
        if CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Draft Item Description") then
            exit;
        CopilotCapability.RegisterCapability(
            Enum::"Copilot Capability"::"Draft Item Description",
            Enum::"Copilot Availability"::Preview, LearnMoreUrlTxt);
    end;
}

codeunit 50204 "Item Copilot Install"
{
    Subtype = Install;
    Access = Internal;

    trigger OnInstallAppPerDatabase()
    var
        ItemCopilotRegistration: Codeunit "Item Copilot Registration";
    begin
        ItemCopilotRegistration.RegisterCapability();
    end;
}

codeunit 50205 "Item Copilot Upgrade"
{
    Subtype = Upgrade;
    Access = Internal;

    trigger OnUpgradePerDatabase()
    var
        ItemCopilotRegistration: Codeunit "Item Copilot Registration";
    begin
        ItemCopilotRegistration.RegisterCapability();
    end;
}
