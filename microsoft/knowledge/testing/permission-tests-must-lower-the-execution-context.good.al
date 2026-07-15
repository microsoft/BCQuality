permissionset 50480 "LIMITED USER"
{
    Assignable = false;
    Permissions =
        tabledata Customer = R,
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

    var
        Assert: Codeunit "Library Assert";
}
