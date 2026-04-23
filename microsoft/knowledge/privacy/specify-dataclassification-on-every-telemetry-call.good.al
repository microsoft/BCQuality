codeunit 50912 "Privacy Sample Telemetry Good"
{
    procedure LogProcessed(var Customer: Record Customer)
    var
        CategoryTok: Label 'CustomerProcessing', Locked = true;
        ProcessedMsgTxt: Label 'Customer record processed.';
    begin
        // Generic message. Business identifier in a custom dimension,
        // never a free-text personal name.
        Session.LogMessage(
            '0000001', ProcessedMsgTxt, Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            'Category', CategoryTok,
            'CustomerNo', Customer."No.");
    end;
}
