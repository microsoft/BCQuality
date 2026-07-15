codeunit 50212 "Privacy Sample Telemetry Good"
{
    procedure LogCustomerProcessed(var Customer: Record Customer)
    begin
        Session.LogMessage('PRIV0001', 'Customer record processed', Verbosity::Normal,
            DataClassification::SystemMetadata, TelemetryScope::All,
            'Category', 'Privacy');
    end;

    procedure LogFileError()
    begin
        Session.LogMessage('PRIV0002', 'Error processing uploaded file', Verbosity::Error,
            DataClassification::SystemMetadata, TelemetryScope::All);
    end;
}
