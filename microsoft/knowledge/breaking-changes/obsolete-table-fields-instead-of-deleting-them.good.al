table 50310 "Customer Profile Good"
{
    fields
    {
        field(1; "No."; Code[20]) { }
        // Replacement field shipped alongside the old one.
        field(2; "Contact Email"; Text[80]) { }
        // Old field kept and marked Pending so dependent code keeps compiling and
        // an upgrade codeunit can copy its data before it is finally removed.
        field(3; "Email"; Text[80])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced by Contact Email. Will be removed after the deprecation window.';
            ObsoleteTag = '25.0';
        }
    }
}
