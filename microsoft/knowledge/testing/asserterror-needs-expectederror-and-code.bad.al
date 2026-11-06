// [FEATURE] Customer master data
codeunit 50409 "Test AssertError Bad"
{
    Subtype = Test;

    [Test]
    procedure BlankNameIsRejectedWithSpecificError()
    var
        Customer: Record Customer;
    begin
        // [SCENARIO] A customer record with a blank name raises a mandatory field error
        // [GIVEN] a customer record with a blank name
        Customer.Init();
        Customer.Name := '';

        // [WHEN] the name field is checked as mandatory
        // [THEN] the blank name is rejected by the mandatory field check
        // Bare asserterror: passes if ANY error is raised. A relation error,
        // a permission error, or a typo elsewhere would all satisfy it — so
        // this never proves the blank-name guard is the thing that fired.
        asserterror Customer.TestField(Name);
    end;
}
