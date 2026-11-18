table 50365 "Sample Connection Setup Bad"
{
    Caption = 'Connection Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "API Key"; Text[250])
        {
            Caption = 'API Key';
            // Masking is treated as protection: the value is still sent to the browser
            // and is readable by anything with permission on the table.
            MaskType = Concealed;
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}
