enumextension 50100 "Sales Review Agent Metadata" extends "Agent Metadata Provider"
{
    value(50100; "Sales Review Agent")
    {
        Caption = 'Sales Review Agent';
        Implementation = IAgentFactory = "Sales Review Agent Factory",
                         IAgentMetadata = "Sales Review Agent Metadata",
                         IAgentTaskExecution = "Sales Review Agent Task";
    }
}

codeunit 50101 "Sales Review Agent Install"
{
    Subtype = Install;
    Access = Internal;

    trigger OnInstallAppPerDatabase()
    begin
        // Agent type exists, but no Copilot Capability value and no RegisterCapability.
    end;
}
