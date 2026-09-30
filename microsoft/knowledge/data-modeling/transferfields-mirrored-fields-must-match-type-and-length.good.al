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
        // Same field number, same type, same length as the Sales Header
        // extension above. SalesInvHeader.TransferFields(SalesHeader) in
        // SalesPost.Codeunit.al only bridges two fields that agree on all
        // three - matching all three here is what makes this value
        // survive posting for every possible "Reference No." value.
        field(50000; "Reference No."; Code[20])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;
        }
    }
}
