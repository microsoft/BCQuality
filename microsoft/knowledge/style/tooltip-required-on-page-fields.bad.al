tableextension 50251 "Sample Tooltip Bad Ext" extends Customer
{
    fields
    {
        field(50251; "Reward Level"; Code[10])
        {
            Caption = 'Reward Level';
            DataClassification = CustomerContent;
        }
    }
}

page 50251 "Sample Tooltip Bad"
{
    PageType = Card;
    SourceTable = Customer;
    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Reward Level"; Rec."Reward Level")
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec."Balance (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = '';
                }
            }
        }
    }
}
