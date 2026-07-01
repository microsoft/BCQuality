codeunit 50136 "Telemetry Bad Sample"
{
    procedure LogSyncDiagnostic(RecordsProcessed: Integer)
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        Dimensions.Add('recordsProcessed', Format(RecordsProcessed));

        // TelemetryScope::All pushes this internal diagnostic into every
        // customer's Application Insights too, inflating their ingestion cost
        // and burying their own signals in noise. ExtensionPublisher is the
        // correct scope for publisher-only diagnostics.
        Session.LogMessage(
            'SYNC001', 'Nightly sync completed.', Verbosity::Normal,
            DataClassification::SystemMetadata, TelemetryScope::All, Dimensions);
    end;
}
