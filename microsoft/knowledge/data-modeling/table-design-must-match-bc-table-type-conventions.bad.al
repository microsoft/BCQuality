table 50121 "Sample Ledger Entry"
{
    fields
    {
        // Anti-pattern: a Ledger table's key must never be user-editable.
        field(1; "Entry No."; Integer) { }
        field(2; "Posting Date"; Date) { }
        field(3; Amount; Decimal) { }
    }
    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
    // No AutoIncrement, no guard against manual insert/delete — a user or
    // integration can renumber or remove entries, breaking the Ledger
    // type's audit-trail guarantee.
}
