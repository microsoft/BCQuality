codeunit 50226 "Sec Sample SwallowErr Good"
{
    procedure Authenticate(): Boolean
    begin
        if TryAuthenticate() then
            exit(true);

        LogAuthFailure(GetLastErrorText());
        exit(false);
    end;

    [TryFunction]
    local procedure TryAuthenticate()
    begin
        // ...
    end;

    local procedure LogAuthFailure(Detail: Text)
    begin
        Session.LogMessage('SEC0001', 'Authentication failed', Verbosity::Warning,
            DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher,
            'Detail', Detail);
    end;
}
