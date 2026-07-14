table 50122 "FieldError vs TestField Good"
{
    fields
    {
        field(1; "No."; Code[20]) { }
        field(2; "Posting Date"; Date) { }
        field(3; "Amount"; Decimal) { }
    }

    procedure PostDocument()
    begin
        // TestField performs this simple presence check and raises only when
        // the field is empty. Self-documenting prerequisite.
        TestField("Posting Date");

        // Business logic has already determined the value is invalid;
        // FieldError raises a tailored, record-aware message with no
        // condition of its own.
        if IsAmountOutsideAllowedRange("Amount") then
            FieldError("Amount", 'is outside the approved posting range');
    end;

    local procedure IsAmountOutsideAllowedRange(Value: Decimal): Boolean
    begin
        exit((Value < 0) or (Value > 1000000));
    end;
}
