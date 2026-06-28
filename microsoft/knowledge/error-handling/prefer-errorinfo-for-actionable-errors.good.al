table 50180 "Actionable Error Good Sample"
{
    fields
    {
        field(1; "Entry No."; Integer) { }
        field(2; "Qty. to Invoice"; Decimal)
        {
            trigger OnValidate()
            var
                CannotInvoiceErr: ErrorInfo;
            begin
                if "Qty. to Invoice" > MaxQtyToInvoice() then begin
                    CannotInvoiceErr.Title := 'Qty. to Invoice isn''t valid';
                    CannotInvoiceErr.Message := StrSubstNo('You cannot invoice more than %1 units.', MaxQtyToInvoice());
                    CannotInvoiceErr.DetailedMessage := 'Reduce the quantity to invoice, or apply the maximum allowed.';
                    CannotInvoiceErr.RecordId := Rec.RecordId();
                    CannotInvoiceErr.AddAction(
                        StrSubstNo('Set value to %1', MaxQtyToInvoice()),
                        Codeunit::"Actionable Error Fixit Sample",
                        'SetQtyToMax');
                    Error(CannotInvoiceErr);
                end;
            end;
        }
    }

    local procedure MaxQtyToInvoice(): Decimal
    begin
        exit(10);
    end;
}

codeunit 50181 "Actionable Error Fixit Sample"
{
    procedure SetQtyToMax(SourceError: ErrorInfo)
    var
        Line: Record "Actionable Error Good Sample";
    begin
        if Line.Get(SourceError.RecordId) then begin
            Line.Validate("Qty. to Invoice", 10);
            Line.Modify(true);
        end;
    end;
}
