tableextension 50250 "Sample Tooltip Good Ext" extends Customer
{
    fields
    {
        field(50250; "Loyalty Points"; Integer)
        {
            Caption = 'Loyalty Points';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the number of loyalty points the customer has collected.';
        }
    }
}

page 50250 "Sample Tooltip Good"
{
    PageType = Card;
    SourceTable = Customer;
    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Loyalty Points"; Rec."Loyalty Points")
                {
                    ApplicationArea = All;
                }
                field(BalanceDue; BalanceDueAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Balance Due';
                    ToolTip = 'Shows the total balance due in local currency.';
                }
            }
        }
    }

    var
        BalanceDueAmount: Decimal;
}
