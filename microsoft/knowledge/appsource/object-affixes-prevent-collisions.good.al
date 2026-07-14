// Own object: the affix "ABC" is carried at object-name level.
table 50377 "ABC Loyalty Tier"
{
    Caption = 'Loyalty Tier';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}

// Extension of a standard object: the added field is individually affixed,
// because the object name (Customer) belongs to the base application.
tableextension 50376 "ABC Customer Ext" extends Customer
{
    fields
    {
        field(50376; "Loyalty Points ABC"; Integer)
        {
            Caption = 'Loyalty Points';
            DataClassification = CustomerContent;
        }
    }
}
