codeunit 50229 "Sec Sample EventPublisher Bad"
{
    [IntegrationEvent(false, false)]
    local procedure OnBeforeExportCustomer(CustomerNo: Code[20]; ExportCredentials: SecretText; var AllowExport: Boolean)
    begin
    end;

    procedure ExportCustomer(CustomerNo: Code[20]; Credentials: SecretText)
    var
        AllowExport: Boolean;
    begin
        // Any subscriber on the tenant receives the credentials and
        // can flip AllowExport := true to bypass the publisher's check.
        OnBeforeExportCustomer(CustomerNo, Credentials, AllowExport);
        if not AllowExport then
            exit;
        // ... perform export
    end;
}
