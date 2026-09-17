codeunit 50411 "Telemetry Dimension Good"
{
    procedure LogBatchResult(RecordCount: Integer)
    var
        CustomDimensions: Dictionary of [Text, Text];
    begin
        CustomDimensions.Add('RecordCount', Format(RecordCount));
        CustomDimensions.Add('Result', 'Success');
        Session.LogMessage(
            'TLM0015', 'Order processing completed', Verbosity::Normal,
            DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher,
            CustomDimensions);
    end;
}
