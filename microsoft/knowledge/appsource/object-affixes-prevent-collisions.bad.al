// Anti-pattern: an own object with no affix. Another app that also defines a
// "Loyalty Tier" table cannot be installed alongside this one.
table 50379 "Loyalty Tier"
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

// Anti-pattern (the common half-measure): the extension object carries the
// affix, but the field it adds to the standard Customer table does not. That
// unaffixed field still collides with any other app that adds "Loyalty Points"
// to Customer, and AS0011 flags it.
tableextension 50378 "ABC Customer Ext" extends Customer
{
    fields
    {
        field(50378; "Loyalty Points"; Integer)
        {
            Caption = 'Loyalty Points';
            DataClassification = CustomerContent;
        }
    }
}
