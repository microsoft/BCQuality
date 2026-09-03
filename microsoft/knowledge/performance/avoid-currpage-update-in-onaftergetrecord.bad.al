page 50100 "CurrPage Update OAGR Bad"
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
        // Update from OnAfterGetRecord re-enters the trigger on every row.
        CurrPage.Update(false);
    end;
}
