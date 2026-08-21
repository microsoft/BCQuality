table 50100 "G/L Entry Extra"
{
    Caption = 'G/L Entry Extra';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            TableRelation = "G/L Entry"."Entry No.";
        }
        field(2; "External Reference"; Text[50]) { }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}
