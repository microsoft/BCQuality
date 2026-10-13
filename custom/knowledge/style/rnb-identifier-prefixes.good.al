tableextension 50100 "RNB Customer Extension" extends Customer
{
    fields
    {
        field(50100; "RNB External Reference"; Code[20])
        {
            Caption = 'External reference';
            DataClassification = CustomerContent;
        }
    }
}

pageextension 50100 "RNB Customer Card Extension" extends "Customer Card"
{
    actions
    {
        addlast(Processing)
        {
            action("RNB Refresh Reference")
            {
                ApplicationArea = All;
                Caption = 'Refresh reference';
                Image = Refresh;

                trigger OnAction()
                begin
                end;
            }
        }
    }
}