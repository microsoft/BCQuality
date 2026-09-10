tableextension 50100 "Sample Sales Header Ext" extends "Sales Header"
{
    fields
    {
        field(50000; "Reference No."; Code[20])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;
        }
    }
}

tableextension 50101 "Sample Sales Invoice Header Ext" extends "Sales Invoice Header"
{
    fields
    {
        // WRONG: same field number 50000, but a shorter length than the
        // Sales Header extension above. This compiles fine and posts
        // fine for every "Reference No." of 10 characters or less -
        // SalesInvHeader.TransferFields(SalesHeader) in
        // SalesPost.Codeunit.al only throws once an actual value longer
        // than 10 characters reaches posting, which typical test data
        // never triggers.
        field(50000; "Reference No."; Code[10])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;
        }
    }
}
