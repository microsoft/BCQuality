// Existing published table, upgraded on runtime 18.0+.
// Field 1 was Integer; widening preserves its ID, key shape, and existing data.
table 50232 "Sample Ledger Entry"
{
    fields
    {
        field(1; "Entry No."; BigInteger) { }
        field(2; "Customer No."; Code[20]) { }
        field(3; "Posting Date"; Date) { }
    }
    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(ByCustomer; "Customer No.", "Posting Date") { }
    }
}
