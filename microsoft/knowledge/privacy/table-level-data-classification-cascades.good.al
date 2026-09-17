table 50202 "System Configuration Log"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer)
        {
        }
        field(2; "Setting Name"; Text[100])
        {
        }
        field(3; "Changed At"; DateTime)
        {
        }
        field(4; "Changed By"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}

tableextension 50203 "System Config Log Correlation" extends "System Configuration Log"
{
    fields
    {
        // A table extension cannot set the table-level property and does not inherit
        // the base table's default, so this field must classify itself even though
        // SystemMetadata is the value the base table already declares.
        field(50203; "Correlation Id"; Guid)
        {
            DataClassification = SystemMetadata;
        }
    }
}
