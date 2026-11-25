table 50120 "Sample Ledger Entry"
{
    fields
    {
        // BigInteger is a valid ledger key; Integer remains valid where sufficient.
        field(1; "Entry No."; BigInteger) { AutoIncrement = true; }
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
