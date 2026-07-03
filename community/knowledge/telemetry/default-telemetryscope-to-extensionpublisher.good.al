codeunit 50136 "Telemetry Good Sample"
{
    procedure LogSyncDiagnostic(RecordsProcessed: Integer)
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        Dimensions.Add('recordsProcessed', Format(RecordsProcessed));

        // A diagnostic only the publisher acts on: route it to the publisher's
        // own Application Insights, not the customer's environment resource.
        Session.LogMessage(
            'SYNC001', 'Nightly sync completed.', Verbosity::Normal,
            DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, Dimensions);
    end;
}
