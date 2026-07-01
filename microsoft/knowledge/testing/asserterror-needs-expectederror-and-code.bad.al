codeunit 50409 "Test AssertError Bad"
{
    Subtype = Test;

    [Test]
    procedure BlankNameIsRejectedWithSpecificError()
    var
        Customer: Record Customer;
    begin
        Customer.Init();
        Customer.Name := '';

        // Bare asserterror: passes if ANY error is raised. A relation error,
        // a permission error, or a typo elsewhere would all satisfy it — so
        // this never proves the blank-name guard is the thing that fired.
        asserterror Customer.TestField(Name);
    end;
}
