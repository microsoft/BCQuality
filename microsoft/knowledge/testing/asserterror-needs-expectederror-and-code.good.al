codeunit 50408 "Test AssertError Good"
{
    Subtype = Test;

    [Test]
    procedure BlankNameIsRejectedWithSpecificError()
    var
        Customer: Record Customer;
    begin
        Customer.Init();
        Customer.Name := '';

        // [WHEN] a mandatory field is blank
        asserterror Customer.TestField(Name);

        // [THEN] verify the SPECIFIC failure through a reusable Library helper
        // instead of hardcoding the localized message and the 'TestField' code.
        // ExpectedTestFieldError centralizes that knowledge, so the test keeps
        // working when the caption or code changes; FieldCaption avoids pinning
        // the field name as a literal.
        Assert.ExpectedTestFieldError(Customer.FieldCaption(Name), '');
    end;

    var
        Assert: Codeunit "Library Assert";
}
