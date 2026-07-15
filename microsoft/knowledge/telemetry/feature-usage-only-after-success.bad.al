codeunit 50407 "Feature Usage Bad"
{
    procedure ExchangeDocument(ShouldFail: Boolean)
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUsage(
            'TLM0014', 'Document exchange', 'Document exchanged');

        if not TryExchangeDocument(ShouldFail) then
            exit;
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
