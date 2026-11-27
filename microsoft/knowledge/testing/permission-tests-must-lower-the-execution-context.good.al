// The change adds Insert to CUSTOMER EDITOR so that its users can run the setup action.
// A test lowers the execution context to CUSTOMER EDITOR and runs that action.
permissionset 50485 "CUSTOMER EDITOR"
{
    Assignable = true;
    Permissions =
        tabledata Customer = RI,
        codeunit "Protected Setup Action" = X;
}

codeunit 50481 "Protected Setup Action"
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

codeunit 50482 "Customer Permission Tests"
{
    Subtype = Test;
    TestPermissions = Restrictive;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure CustomerEditorCanRunSetupAction()
    var
        Customer: Record Customer;
        PermissionsMock: Codeunit "Permissions Mock";
        SetupAction: Codeunit "Protected Setup Action";
    begin
        // [FEATURE] [Permissions]
        // [SCENARIO] A user with CUSTOMER EDITOR can run the setup action
        // [GIVEN] The execution context is lowered to CUSTOMER EDITOR
        PermissionsMock.Start();
        PermissionsMock.Set('CUSTOMER EDITOR');

        // [WHEN] The setup action runs
        SetupAction.Run();

        // [THEN] The customer exists, read within what the set grants
        // Removing Insert from CUSTOMER EDITOR makes SetupAction.Run fail with a permission error.
        Customer.SetRange("No.", 'NO-INSERT');
        Assert.RecordCount(Customer, 1);

        PermissionsMock.Stop();
    end;
}
