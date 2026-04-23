codeunit 50907 "Privacy Sample LastErr Bad"
{
    procedure LogFailure()
    var
        CategoryTok: Label 'Sync', Locked = true;
        FailureTxt: Label 'Operation failed: %1', Comment = '%1 = last error text';
    begin
        // GetLastErrorText(true) carries the call stack and field values from
        // the failing context. Declared as SystemMetadata but the payload is CustomerContent.
        Session.LogMessage(
            '0000ABC', StrSubstNo(FailureTxt, GetLastErrorText(true)),
            Verbosity::Error,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;
}
