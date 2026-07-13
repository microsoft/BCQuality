table 50361 "Loyalty Member"
{
    Caption = 'Loyalty Member';
    DataClassification = CustomerContent;

    fields
    {
        // Anti-pattern: an autoincrement Integer surrogate used as the business key.
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(10; Name; Text[100])
        {
            Caption = 'Name';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    // No OnInsert, no number series, no "No." code, and no "No. Series" field.
    // Records get an opaque integer users never see and cannot quote on the phone,
    // and the master is cut off from BC's standard numbering and manual-entry flow.
}
