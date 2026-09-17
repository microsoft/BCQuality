codeunit 50400 "Telemetry Scope Good"
{
    procedure LogIntegrationFailure()
    begin
        Session.LogMessage(
            'TLM0002',
            'Document exchange failed',
            Verbosity::Error,
            DataClassification::SystemMetadata,
            TelemetryScope::All,
            'Operation', 'DocumentExchange');
    end;

    procedure LogCacheMiss()
    begin
        Session.LogMessage(
            'TLM0003',
            'Internal cache entry missed',
            Verbosity::Verbose,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            'Cache', 'ExchangeMetadata');
    end;
}
