table 50908 "Privacy Sample Override Good"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer) { }
        field(2; "Customer Name"; Text[100])
        {
            // Table default is SystemMetadata; this field is personal data.
            DataClassification = CustomerContent;
        }
        field(3; "E-Mail"; Text[80])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Logged At"; DateTime) { }
    }
    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}
