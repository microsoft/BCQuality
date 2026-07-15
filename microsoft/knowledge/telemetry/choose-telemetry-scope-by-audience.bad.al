codeunit 50401 "Telemetry Scope Bad"
{
    procedure LogIntegrationFailure()
    begin
        // Tenant operators cannot see an actionable integration failure.
        Session.LogMessage(
            'TLM0004',
            'Document exchange failed',
            Verbosity::Error,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            'Operation', 'DocumentExchange');
    end;

    procedure LogCacheMiss()
    begin
        // Environment telemetry receives publisher-only implementation noise.
        Session.LogMessage(
            'TLM0005',
            'Internal cache entry missed',
            Verbosity::Verbose,
            DataClassification::SystemMetadata,
            TelemetryScope::All,
            'Cache', 'ExchangeMetadata');
    end;
}
