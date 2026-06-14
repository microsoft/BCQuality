codeunit 50102 "Customer Permission Tests"
{
    Subtype = Test;
    TestPermissions = Restrictive;
    var
        Assert: Codeunit Assert;

    [Test]
    procedure CustomerReadFailsWithoutPermission()
    var
        Customer: Record Customer;
    begin
        // Restrictive: test runner assigns no permission sets to the test user.
        asserterror Customer.FindFirst();
        Assert.ExpectedError('You do not have the following permissions');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AdminCanReadAllCustomers()
    var
        Customer: Record Customer;
    begin
        // Disabled overrides codeunit-level Restrictive for this test only.
        // Use for paths that legitimately require elevated access.
        Customer.FindFirst();
    end;
}
