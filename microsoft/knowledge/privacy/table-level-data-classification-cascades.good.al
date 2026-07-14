table 50202 "System Configuration Log"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Changed By"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Change Description"; Text[250])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}
