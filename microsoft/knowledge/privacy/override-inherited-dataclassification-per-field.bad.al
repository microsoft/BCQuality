table 50909 "Privacy Sample Override Bad"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer) { }
        // Customer name inherits SystemMetadata from the table. Subject-access
        // and retention tooling treats the value as system housekeeping.
        field(2; "Customer Name"; Text[100]) { }
        field(3; "E-Mail"; Text[80]) { }
        field(4; "Logged At"; DateTime) { }
    }
    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}
