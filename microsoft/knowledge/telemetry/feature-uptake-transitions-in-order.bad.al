codeunit 50405 "Feature Uptake Bad"
{
    procedure FeatureOpened()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        // The first uptake state skips Discovered and is not emitted.
        FeatureTelemetry.LogUptake(
            'TLM0011', 'Document exchange', Enum::"Feature Uptake Status"::Used);
    end;
}
