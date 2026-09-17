enumextension 50100 "Sales Review Agent Metadata" extends "Agent Metadata Provider"
{
    value(50100; "Sales Review Agent")
    {
        Caption = 'Sales Review Agent';
        // Only factory is bound. Metadata UI and task execution never resolve.
        Implementation = IAgentFactory = "Sales Review Agent Factory";
    }
}
