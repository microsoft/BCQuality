codeunit 50228 "Sec Sample EventPublisher Good"
{
    [IntegrationEvent(false, false)]
    local procedure OnBeforeExportCustomer(CustomerNo: Code[20])
    begin
    end;

    procedure ExportCustomer(CustomerNo: Code[20])
    begin
        if not CallerIsAuthorizedToExport(CustomerNo) then
            Error('You are not authorized to export this customer.');

        OnBeforeExportCustomer(CustomerNo);
        // ... perform export using credentials owned by this codeunit
    end;

    local procedure CallerIsAuthorizedToExport(CustomerNo: Code[20]): Boolean
    begin
        // Authorization decision stays inside the publisher. Subscribers
        // receive only the customer number and cannot influence the
        // decision.
    end;
}
