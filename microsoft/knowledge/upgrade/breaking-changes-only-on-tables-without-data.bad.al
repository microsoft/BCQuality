// Published field 1 was BigInteger and can contain values above 2,147,483,647.
// Narrowing it to Integer is not the supported Integer-to-BigInteger conversion.
table 50233 "Sample Ledger Entry Bad"
{
    fields
    {
        field(1; "Entry No."; Integer) { }
        field(2; "Customer No."; Code[20]) { }
        field(3; "Posting Date"; Date) { }
    }
    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(ByCustomer; "Customer No.", "Posting Date") { }
    }
}
