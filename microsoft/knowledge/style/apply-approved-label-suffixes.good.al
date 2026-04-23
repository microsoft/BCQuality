codeunit 51100 "Style Sample LabelSuffix Good"
{
    procedure Example()
    var
        UpdateCompleteMsg: Label 'Update complete.';
        CannotDeleteLineErr: Label 'Cannot delete this line.';
        UpdateLocationQst: Label 'Update location?';
        CustomerNameLbl: Label 'Customer Name';
        HttpsMethodTok: Label 'GET', Locked = true;
        TelemetryCustomerUpdatedTxt: Label 'Customer updated.';
    begin
        Message(UpdateCompleteMsg);
        if Confirm(UpdateLocationQst) then
            ;
        Session.LogMessage('0001', TelemetryCustomerUpdatedTxt,
            Verbosity::Normal, DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher);
        Error(CannotDeleteLineErr);
    end;
}
