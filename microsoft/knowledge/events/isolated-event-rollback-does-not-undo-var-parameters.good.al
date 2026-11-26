// Demonstration only. Shows the recommended pattern: the override point is a normal event; the isolated event only notifies.

codeunit 50183 "Invoice Export Good"
{
    procedure ExportInvoice(InvoiceNo: Code[20])
    var
        IsHandled: Boolean;
    begin
        // Normal event: a subscriber error propagates, so IsHandled is never consumed half-applied.
        OnBeforeExportInvoice(InvoiceNo, IsHandled);
        if not IsHandled then
            ExportToDefaultChannel(InvoiceNo);
    end;

    procedure NotifyInvoiceExported(InvoiceNo: Code[20])
    begin
        // Called after the export has been committed. By-value parameters only: a failing
        // subscriber cannot change anything the publisher reads afterwards.
        OnAfterInvoiceExported(InvoiceNo);
    end;

    local procedure ExportToDefaultChannel(InvoiceNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExportInvoice(InvoiceNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false, true)]
    local procedure OnAfterInvoiceExported(InvoiceNo: Code[20])
    begin
    end;
}
