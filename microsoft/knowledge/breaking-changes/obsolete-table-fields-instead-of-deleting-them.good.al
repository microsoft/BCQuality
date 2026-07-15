table 50310 "Customer Profile Good"
{
    fields
    {
        field(1; "No."; Code[20]) { }
        // Replacement field receives a new ID in this independent example.
        field(2; "Contact Email"; Text[80]) { }
        // Old field keeps its original ID and is marked Pending so dependent code
        // keeps compiling while an upgrade codeunit migrates its data.
        field(3; "Email"; Text[80])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced by Contact Email. Will be removed after the deprecation window.';
            ObsoleteTag = '25.0';
        }
    }
}
