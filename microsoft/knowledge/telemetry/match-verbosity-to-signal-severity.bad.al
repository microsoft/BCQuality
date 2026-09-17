codeunit 50403 "Telemetry Verbosity Bad"
{
    procedure RunExchange()
    begin
        if TryExchange() then
            exit;

        Session.LogMessage(
            'TLM0007',
            'Document exchange failed',
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::All);
    end;

    [TryFunction]
    local procedure TryExchange()
    begin
        Error(ExchangeFailedErr);
    end;

    var
        ExchangeFailedErr: Label 'Exchange failed.';
}
