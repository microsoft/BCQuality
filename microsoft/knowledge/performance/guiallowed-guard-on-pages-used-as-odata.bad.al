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
                field(Name; Rec.Name)
                {
                    StyleExpr = NameStyle;
                }
            }
        }
    }

    var
        NameStyle: Text;

    trigger OnAfterGetRecord()
    begin
        // UI-only styling still runs for every OData / Edit-in-Excel row.
        Rec.CalcFields("Balance (LCY)");
        if Rec."Balance (LCY)" > 0 then
            NameStyle := 'Attention'
        else
            NameStyle := 'Standard';
    end;
}
