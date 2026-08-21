page 50100 "GuiAllowed OData Guard Good"
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
        if not GuiAllowed then
            exit;
        Rec.CalcFields("Balance (LCY)");
    end;
}
