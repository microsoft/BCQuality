page 50100 "GuiAllowed OData Guard Bad"
{
    PageType = List;
    SourceTable = Customer;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Rows)
            {
                field("No."; Rec."No.") { }
                field(Name; Rec.Name) { }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        // Runs for every OData / Edit-in-Excel row with no UI.
        Rec.CalcFields("Balance (LCY)");
    end;
}
