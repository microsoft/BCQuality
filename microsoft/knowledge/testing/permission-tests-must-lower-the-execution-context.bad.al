codeunit 50483 "Protected Setup Action Bad"
{
    trigger OnRun()
    var
        Customer: Record Customer;
    begin
        Customer.Init();
        Customer."No." := 'SUPER-INSERT';
        Customer.Insert();
    end;
}

codeunit 50484 "Permission Test Bad"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure LimitedUserCannotRunSetup()
    var
        SetupAction: Codeunit "Protected Setup Action Bad";
    begin
        // Disabled runs as SUPER; no limited-user boundary is exercised.
        asserterror SetupAction.Run();
    end;
}
