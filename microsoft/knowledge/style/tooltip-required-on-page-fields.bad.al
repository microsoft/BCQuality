page 50251 "Sample Tooltip Bad"
{
    PageType = Card;
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
                    Caption = 'Customer No.';
                }
                field(PreviewAmount; PreviewAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Preview Amount';
                    ToolTip = '';
                }
            }
        }
    }

    var
        CustomerNoValue: Code[20];
        PreviewAmount: Decimal;
}
