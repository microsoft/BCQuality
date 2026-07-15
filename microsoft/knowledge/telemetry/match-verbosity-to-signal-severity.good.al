codeunit 50402 "Telemetry Verbosity Good"
{
    procedure RunExchange()
    begin
        if TryExchange() then
            exit;

        Session.LogMessage(
            'TLM0006',
            'Document exchange failed',
            Verbosity::Error,
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
