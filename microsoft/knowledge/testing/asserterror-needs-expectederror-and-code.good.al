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

        // [THEN] verify the SPECIFIC failure — message and code — not just "any error"
        Assert.ExpectedError('Name must have a value');
        Assert.ExpectedErrorCode('TestField');
    end;

    var
        Assert: Codeunit "Library Assert";
}
