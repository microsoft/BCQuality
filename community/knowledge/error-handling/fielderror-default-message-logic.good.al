table 50120 "FieldError Default Good"
{
    fields
    {
        field(1; "No."; Code[20]) { }
        field(2; "Discount %"; Decimal) { }
        field(3; "Currency Code"; Code[10]) { }
    }

    procedure ValidateForRelease()
    begin
        // Plain required-field gate: TestField checks the condition and raises
        // the error in one call, with caption and record context supplied by
        // the framework.
        TestField("Currency Code");

        // Condition already evaluated: pass only a lowercase predicate so it
        // reads as one sentence after the auto-inserted caption and value.
        if "Discount %" > 100 then
            FieldError("Discount %", 'cannot exceed 100');
    end;
}
