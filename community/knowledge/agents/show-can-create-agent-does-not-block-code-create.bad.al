codeunit 50100 "Sales Review Agent Factory"
{
    procedure ShowCanCreateAgent(): Boolean
    begin
        // Author intends this to forbid all creates. It only hides the UI tile.
        exit(false);
    end;
}

pageextension 50100 "Sales Order List Agent Create" extends "Sales Order List"
{
    actions
    {
        addlast(Processing)
        {
            action(CreateAgent)
            {
                ApplicationArea = All;
                Caption = 'Create review agent';

                trigger OnAction()
                var
                    Agent: Codeunit Agent;
                    TempAgentAccessControl: Record "Agent Access Control" temporary;
                begin
                    // Still succeeds for any caller with permission to run this action.
                    Agent.Create(
                        Enum::"Agent Metadata Provider"::"Sales Review Agent",
                        'SALESREVIEW',
                        'Sales Review Agent',
                        TempAgentAccessControl);
                end;
            }
        }
    }
}
