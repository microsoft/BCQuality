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
        if not GuiAllowed then
            exit;
        Rec.CalcFields("Balance (LCY)");
        if Rec."Balance (LCY)" > 0 then
            NameStyle := 'Attention'
        else
            NameStyle := 'Standard';
    end;
}
