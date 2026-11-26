// [FEATURE] Customer master data
codeunit 50408 "Test AssertError Good"
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
        asserterror Customer.TestField(Name);

        // [THEN] the blank name is rejected by the mandatory field check
        // Verify the SPECIFIC failure through a reusable Library helper
        // instead of hardcoding the localized message and the 'TestField' code.
        // ExpectedTestFieldError centralizes that knowledge, so the test keeps
        // working when the caption or code changes; FieldCaption avoids pinning
        // the field name as a literal.
        Assert.ExpectedTestFieldError(Customer.FieldCaption(Name), '');
    end;

    var
        Assert: Codeunit "Library Assert";
}
