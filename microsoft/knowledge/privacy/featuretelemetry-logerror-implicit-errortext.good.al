codeunit 50309 "LogError Privacy Good"
{
    procedure SendInvoice()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        CustomDimensions: Dictionary of [Text, Text];
        ErrorCallStack: Text;
        ErrorText: Text;
    begin
        if TrySendInvoice() then
            exit;

        ErrorText := GetLastErrorText(true);
        ErrorCallStack := GetLastErrorCallStack();
        CustomDimensions.Add('Operation', 'SendInvoice');
        FeatureTelemetry.LogError('0000FT1', 'Invoice exchange', 'Sending invoice',
            ErrorText, ErrorCallStack, CustomDimensions);
    end;

    [TryFunction]
    local procedure TrySendInvoice()
    begin
        Error(SendFailedErr);
    end;

    var
        SendFailedErr: Label 'The invoice could not be sent.';
}
