page 51202 "Perf Sample ReGetRec Good"
{
    PageType = List;
    SourceTable = "Assembly Line";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        // Rec already holds the current row's values; no Get needed.
        ShowWarning := CheckAvailability(Rec);
    end;

    var
        ShowWarning: Boolean;

    local procedure CheckAvailability(var AssemblyLine: Record "Assembly Line"): Boolean
    begin
        exit(false);
    end;
}
