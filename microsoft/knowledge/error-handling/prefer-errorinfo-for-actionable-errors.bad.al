table 50182 "Actionable Error Bad Sample"
{
    fields
    {
        field(1; "Entry No."; Integer) { }
        field(2; "Qty. to Invoice"; Decimal)
        {
            trigger OnValidate()
            begin
                // Dead-end error: the code knows the maximum but offers the user no way to apply it.
                if "Qty. to Invoice" > MaxQtyToInvoice() then
                    Error('You cannot invoice more than %1 units.', MaxQtyToInvoice());
            end;
        }
    }

    local procedure MaxQtyToInvoice(): Decimal
    begin
        exit(10);
    end;
}
