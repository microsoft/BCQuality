codeunit 50225 "Sec Sample ErrorDisclosure Bad"
{
    procedure Connect()
    begin
        if not TryConnect() then
            Error('Failed to connect to Server=PROD-SQL01;Database=NAV;User=svc_admin: %1', GetLastErrorText());
    end;

    [TryFunction]
    local procedure TryConnect()
    begin
        // ...
    end;
}
