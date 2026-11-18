permissionset 50480 "LIMITED USER"
{
    Assignable = false;
    Permissions =
        tabledata Customer = R,
        codeunit "Protected Setup Action Test" = X;
}

permissionset 50485 "CUSTOMER EDITOR"
{
    Assignable = false;
    Permissions =
        tabledata Customer = RI,
        codeunit "Protected Setup Action Test" = X;
}

codeunit 50481 "Protected Setup Action Test"
{
    trigger OnRun()
    var
        Customer: Record Customer;
    begin
        Customer.Init();
        Customer."No." := 'NO-INSERT';
        Customer.Insert();
    end;
}

codeunit 50482 "Permission Test Good"
{
    Subtype = Test;
    TestPermissions = Restrictive;

    [Test]
    procedure LimitedUserCannotRunSetup()
    var
        PermissionsMock: Codeunit "Permissions Mock";
        SetupAction: Codeunit "Protected Setup Action Test";
    begin
        PermissionsMock.Start();
        PermissionsMock.SetExactPermissionSet('LIMITED USER');

        asserterror SetupAction.Run();
        Assert.ExpectedError('permission');

        PermissionsMock.Stop();
    end;

    [Test]
    procedure EditorCanRunSetup()
    var
        Customer: Record Customer;
        PermissionsMock: Codeunit "Permissions Mock";
        SetupAction: Codeunit "Protected Setup Action Test";
    begin
        // The positive side: the set grants what the operation needs.
        // Removing 'I' from CUSTOMER EDITOR makes SetupAction.Run fail with a permission error.
        PermissionsMock.Start();
        PermissionsMock.Set('CUSTOMER EDITOR');

        SetupAction.Run();

        // Verify within what the set grants (R); the test runner stops the mock after the test.
        Customer.SetRange("No.", 'NO-INSERT');
        Assert.RecordCount(Customer, 1);
    end;

    var
        Assert: Codeunit "Library Assert";
}
