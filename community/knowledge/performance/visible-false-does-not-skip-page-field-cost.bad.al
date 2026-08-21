page 50100 "Visible False Page Cost Bad"
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
                // Hidden still participates in page load / FlowField calculation.
                field("Balance (LCY)"; Rec."Balance (LCY)")
                {
                    Visible = false;
                }
            }
        }
    }
}
