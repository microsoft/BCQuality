codeunit 50406 "Feature Usage Good"
{
    procedure ExchangeDocument(ShouldFail: Boolean)
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        if not TryExchangeDocument(ShouldFail) then begin
            FeatureTelemetry.LogError(
                'TLM0012', 'Document exchange', 'Exchanging document',
                GetLastErrorText(true), GetLastErrorCallStack());
            exit;
        end;

        FeatureTelemetry.LogUsage(
            'TLM0013', 'Document exchange', 'Document exchanged');
    end;

    [TryFunction]
    local procedure TryExchangeDocument(ShouldFail: Boolean)
    begin
        if ShouldFail then
            Error(ExchangeFailedErr);
    end;

    var
        ExchangeFailedErr: Label 'Exchange failed.';
}
