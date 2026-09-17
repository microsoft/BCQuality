enumextension 50101 "Sales Review Agent Copilot" extends "Copilot Capability"
{
    value(50101; "Sales Review Agent")
    {
        Caption = 'Sales Review Agent';
    }
}

codeunit 50101 "Sales Review Agent Install"
{
    Subtype = Install;
    Access = Internal;

    trigger OnInstallAppPerDatabase()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        LearnMoreUrlTxt: Label 'https://example.com/sales-review-agent', Locked = true;
    begin
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Sales Review Agent") then
            CopilotCapability.RegisterCapability(
                Enum::"Copilot Capability"::"Sales Review Agent",
                Enum::"Copilot Availability"::Preview,
                Enum::"Copilot Billing Type"::"Microsoft Billed",
                LearnMoreUrlTxt);
    end;
}
