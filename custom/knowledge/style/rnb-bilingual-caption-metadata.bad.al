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