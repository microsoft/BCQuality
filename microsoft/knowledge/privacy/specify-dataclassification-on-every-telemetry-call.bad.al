codeunit 50913 "Privacy Sample Telemetry Bad"
{
    procedure LogProcessed(var Customer: Record Customer)
    var
        CategoryTok: Label 'CustomerProcessing', Locked = true;
        MsgTemplateTxt: Label 'Processed customer %1', Comment = '%1 = customer name';
    begin
        // Declared SystemMetadata; payload is CustomerContent. The message is
        // opaque text once built; the pipeline cannot redact.
        Session.LogMessage(
            '0000001', StrSubstNo(MsgTemplateTxt, Customer.Name),
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::All, 'Category', CategoryTok);
    end;
}
