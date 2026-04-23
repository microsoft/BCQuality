page 51203 "Perf Sample ReGetRec Bad"
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
    var
        AssemblyLineRec: Record "Assembly Line";
    begin
        // Redundant Get. The page runtime already loaded this row into Rec.
        // At list-page scale this fires hundreds of times per scroll.
        AssemblyLineRec.Get(Rec."Document Type", Rec."Document No.", Rec."Line No.");
        ShowWarning := CheckAvailability(AssemblyLineRec);
    end;

    var
        ShowWarning: Boolean;

    local procedure CheckAvailability(var AssemblyLine: Record "Assembly Line"): Boolean
    begin
        exit(false);
    end;
}
