codeunit 50404 "Feature Uptake Good"
{
    procedure FeatureDiscovered()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake(
            'TLM0008', 'Document exchange', Enum::"Feature Uptake Status"::Discovered);
    end;

    procedure FeatureSetUp()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake(
            'TLM0009', 'Document exchange', Enum::"Feature Uptake Status"::"Set up");
    end;

    procedure FeatureUsed()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake(
            'TLM0010', 'Document exchange', Enum::"Feature Uptake Status"::Used);
    end;
}
