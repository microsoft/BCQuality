codeunit 50310 "LogError Privacy Bad"
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

        ErrorText := GetLastErrorText();
        ErrorCallStack := GetLastErrorCallStack();
        CustomDimensions.Add('Operation', 'SendInvoice');
        FeatureTelemetry.LogError('0000FT2', 'Invoice exchange', 'Sending invoice',
            ErrorText, ErrorCallStack, CustomDimensions);
    end;

    [TryFunction]
    local procedure TrySendInvoice()
    begin
        Error('Invoice %1 for %2 could not be sent.', 'INV-1001', 'user@example.com');
    end;
}
