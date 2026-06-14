codeunit 50103 "Customer Permission Tests"
{
    Subtype = Test;
    // No TestPermissions - defaults to Disabled. All tests run as SUPER.

    [Test]
    procedure CustomerReadSucceeds()
    var
        Customer: Record Customer;
    begin
        // SUPER always has read access. This passes even when the real user
        // calling this feature in production has no Customer read permission.
        // The test never catches a permission gap. False confidence.
        Customer.FindFirst();
    end;
}
