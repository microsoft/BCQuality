// Demonstration only. Shows the wrong pattern: an isolated event used as an IsHandled override point.

codeunit 50182 "Invoice Export Bad"
{
    procedure ExportInvoice(InvoiceNo: Code[20])
    var
        IsHandled: Boolean;
    begin
        // BAD: a subscriber can set IsHandled := true and then fail. Its table writes are rolled
        // back, but IsHandled keeps the value true, so the default export is silently skipped.
        OnBeforeExportInvoice(InvoiceNo, IsHandled);
        if IsHandled then
            exit;

        ExportToDefaultChannel(InvoiceNo);
    end;

    local procedure ExportToDefaultChannel(InvoiceNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false, true)]
    local procedure OnBeforeExportInvoice(InvoiceNo: Code[20]; var IsHandled: Boolean)
    begin
    end;
}
