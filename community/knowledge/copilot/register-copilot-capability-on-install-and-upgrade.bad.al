// Demonstration only. Shows the wrong pattern: the capability is registered only when the app is first installed.

enumextension 50200 "Item Description Capability" extends "Copilot Capability"
{
    value(50200; "Draft Item Description")
    {
        Caption = 'Draft item description';
    }
}

codeunit 50201 "Item Copilot Install Bad"
{
    Subtype = Install;
    Access = Internal;

    trigger OnInstallAppPerDatabase()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        LearnMoreUrlTxt: Label 'https://example.com/item-description-copilot', Locked = true;
    begin
        // BAD: tenants that already run an earlier version of this app receive the capability through
        // an upgrade, so this trigger never runs for them and the capability stays unregistered.
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Draft Item Description") then
            CopilotCapability.RegisterCapability(
                Enum::"Copilot Capability"::"Draft Item Description",
                Enum::"Copilot Availability"::Preview, LearnMoreUrlTxt);
    end;
}
