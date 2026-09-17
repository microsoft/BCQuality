codeunit 50260 "Telemetry Event Id Bad"
{
    procedure LogCustomerProcessed(var Customer: Record Customer)
    begin
        Session.LogMessage(
            '0000',
            'Customer record processed',
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::All,
            'Category', 'QualitySamples');
    end;
}
