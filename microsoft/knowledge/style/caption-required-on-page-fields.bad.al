page 50253 "Sample Caption Bad"
{
    PageType = Card;
    SourceTable = Customer;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Customer No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Customer Name"; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = '';
                }
            }
        }
    }
}
