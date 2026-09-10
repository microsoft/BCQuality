table 50120 "Sample Ledger Entry"
{
    fields
    {
        // Ledger primary key: Integer "Entry No.", set only by posting.
        field(1; "Entry No."; Integer) { AutoIncrement = true; }
        field(2; "Posting Date"; Date) { }
        field(3; Amount; Decimal) { }
    }
    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
    // No user-facing Insert/Delete/Modify path is exposed; rows are
    // created exclusively by the posting routine.
}
