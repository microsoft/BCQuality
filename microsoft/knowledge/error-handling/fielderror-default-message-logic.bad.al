table 50120 "FieldError Default Bad"
{
    fields
    {
        field(1; "No."; Code[20]) { }
        field(2; "Discount %"; Decimal) { }
        field(3; "Currency Code"; Code[10]) { }
    }

    procedure ValidateForRelease()
    begin
        // This re-tests a field and gives FieldError a fully formed sentence.
        // The framework already prepends the caption and appends the value,
        // so this renders as "Currency Code The Currency Code field must have
        // a value. in ..." — caption repeated, capital letter mid-sentence,
        // stray trailing clause.
        if "Currency Code" = '' then
            FieldError("Currency Code", 'The Currency Code field must have a value.');

        if "Discount %" > 100 then
            FieldError("Discount %", 'The Discount % must not be greater than 100 percent.');
    end;
}
