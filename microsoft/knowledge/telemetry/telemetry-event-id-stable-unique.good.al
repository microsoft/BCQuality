codeunit 50261 "Telemetry Event Id Good"
{
    procedure LogCustomerProcessed(var Customer: Record Customer)
    begin
        Session.LogMessage(
            'QS0001',
            'Customer record processed',
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::All,
            'Category', 'QualitySamples');
    end;
}
