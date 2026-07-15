codeunit 50409 "First Telemetry Logger" implements "Telemetry Logger"
{
    Access = Internal;

    procedure LogMessage(EventId: Text; Message: Text; Verbosity: Verbosity; DataClassification: DataClassification; TelemetryScope: TelemetryScope; CustomDimensions: Dictionary of [Text, Text])
    begin
        Session.LogMessage(
            EventId, Message, Verbosity, DataClassification, TelemetryScope, CustomDimensions);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Telemetry Loggers", 'OnRegisterTelemetryLogger', '', true, true)]
    local procedure RegisterFirst(var Sender: Codeunit "Telemetry Loggers")
    var
        Logger: Codeunit "First Telemetry Logger";
    begin
        Sender.Register(Logger);
    end;
}

codeunit 50410 "Second Telemetry Logger" implements "Telemetry Logger"
{
    Access = Internal;

    procedure LogMessage(EventId: Text; Message: Text; Verbosity: Verbosity; DataClassification: DataClassification; TelemetryScope: TelemetryScope; CustomDimensions: Dictionary of [Text, Text])
    begin
        Session.LogMessage(
            EventId, Message, Verbosity, DataClassification, TelemetryScope, CustomDimensions);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Telemetry Loggers", 'OnRegisterTelemetryLogger', '', true, true)]
    local procedure RegisterSecond(var Sender: Codeunit "Telemetry Loggers")
    var
        Logger: Codeunit "Second Telemetry Logger";
    begin
        Sender.Register(Logger);
    end;
}
