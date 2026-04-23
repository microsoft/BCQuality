page 51003 "UI Sample FieldTooltip Bad"
{
    PageType = Card;
    SourceTable = Customer;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Name"; Rec.Name)
                {
                    ApplicationArea = All;
                    // No "Specifies" opener, no period, a bare fragment.
                    ToolTip = 'The name of the customer';
                }
                field("Balance (LCY)"; Rec."Balance (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Balance';
                }
            }
        }
    }
}
