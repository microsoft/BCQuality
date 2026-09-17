enumextension 50100 "Sales Review Agent Metadata" extends "Agent Metadata Provider"
{
    value(50100; "Sales Review Agent")
    {
        Caption = 'Sales Review Agent';
        Implementation = IAgentFactory = "Sales Review Agent Factory",
                         IAgentMetadata = "Sales Review Agent Meta. Impl.",
                         IAgentTaskExecution = "Sales Review Agent Task";
    }
}
