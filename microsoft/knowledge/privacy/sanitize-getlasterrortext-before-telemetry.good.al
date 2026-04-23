codeunit 50906 "Privacy Sample LastErr Good"
{
    procedure LogFailure()
    var
        CategoryTok: Label 'Sync', Locked = true;
        GenericMsgTxt: Label 'Sync operation failed. See extended log for details.';
    begin
        // Generic message, no GetLastErrorText. Detail goes to an internal log
        // the telemetry pipeline does not receive.
        Session.LogMessage(
            '0000ABC', GenericMsgTxt, Verbosity::Error,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;
}
