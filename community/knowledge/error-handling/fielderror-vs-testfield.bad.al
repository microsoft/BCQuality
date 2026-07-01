table 50122 "FieldError vs TestField Bad"
{
    fields
    {
        field(1; "No."; Code[20]) { }
        field(2; "Posting Date"; Date) { }
        field(3; "Amount"; Decimal) { }
    }

    procedure PostDocument()
    begin
        // FieldError performs no comparison and always raises the moment it is
        // reached, so this "check" terminates PostDocument every time — the
        // Posting Date is never actually tested, and the amount rule below is
        // dead code.
        FieldError("Posting Date", 'must be filled in');

        if IsAmountOutsideAllowedRange("Amount") then
            Error('Amount is out of range.');
    end;

    local procedure IsAmountOutsideAllowedRange(Value: Decimal): Boolean
    begin
        exit((Value < 0) or (Value > 1000000));
    end;
}
