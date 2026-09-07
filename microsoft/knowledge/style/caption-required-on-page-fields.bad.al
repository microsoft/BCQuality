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
                Caption = 'General';
                field(CustomerNoValue; CustomerNoValue)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number to look up.';
                }
                field("Customer Name"; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = '';
                    ToolTip = 'Specifies the customer name shown on sales documents.';
                }
            }
        }
    }

    var
        CustomerNoValue: Code[20];
}
