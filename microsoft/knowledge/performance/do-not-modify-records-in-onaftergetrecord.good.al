page 51208 "Perf Sample NoModifyOAGR Good"
{
    PageType = List;
    SourceTable = Customer;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field(WarningFlag; ShowWarning)
                {
                    ApplicationArea = All;
                    Caption = 'Warning';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        // Page-local variable. No database write per row.
        ShowWarning := CalcWarning(Rec);
    end;

    var
        ShowWarning: Boolean;

    local procedure CalcWarning(var Customer: Record Customer): Boolean
    begin
        exit(false);
    end;
}
