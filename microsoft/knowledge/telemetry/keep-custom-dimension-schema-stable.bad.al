codeunit 50412 "Telemetry Dimension Bad"
{
    procedure LogBatchResult(RecordCount: Integer)
    var
        CustomDimensions: Dictionary of [Text, Text];
    begin
        CustomDimensions.Add('record count', Format(RecordCount));
        CustomDimensions.Add('result_code', 'Success');
        Session.LogMessage(
            'TLM0015', 'Order processing completed', Verbosity::Normal,
            DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher,
            CustomDimensions);
    end;
}
