// Best practice: a scheduled monitor lists the LIVE external event subscriptions and diffs
// them against the EXPECTED set. Any expected subscription that BC has silently dropped
// (because the subscriber returned a non-408/429/5xx response) raises an alert and telemetry.

table 50180 "Expected Event Subscription"
{
    DataClassification = SystemMetadata;

    fields
    {
        // The expected set lives in configuration, so registering an integration also registers
        // its monitoring expectation. The two cannot drift apart.
        field(1; "Event Name"; Text[100]) { Caption = 'Event Name'; }
        field(2; "Notification URL"; Text[250]) { Caption = 'Notification URL'; }
    }

    keys { key(PK; "Event Name", "Notification URL") { Clustered = true; } }
}

codeunit 50181 "Subscription Health Monitor"
{
    TableNo = "Job Queue Entry";

    // Runs as a Job Queue entry on a schedule (for example hourly). It must run actively:
    // a dropped subscription is indistinguishable from a quiet feed, so silence cannot be trusted.
    trigger OnRun()
    begin
        CheckHealth();
    end;

    procedure CheckHealth()
    var
        Expected: Record "Expected Event Subscription";
        Live: List of [Text];
    begin
        // GET api/microsoft/runtime/v1.0/externaleventsubscriptions and project each live
        // subscription to a comparable key.
        Live := FetchLiveSubscriptions();

        if Expected.FindSet() then
            repeat
                // The diff: an expected subscription missing from the live list was dropped by
                // the platform with no notification. That is an incident, not a warning.
                if not Live.Contains(SubscriptionKey(Expected."Event Name", Expected."Notification URL")) then
                    RaiseMissingSubscriptionAlert(Expected);
            until Expected.Next() = 0;
    end;

    local procedure RaiseMissingSubscriptionAlert(Expected: Record "Expected Event Subscription")
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        // Telemetry carries the event name and URL so operations can re-register it AND can read,
        // from the telemetry timeline, roughly when delivery stopped.
        Dimensions.Add('eventName', Expected."Event Name");
        Dimensions.Add('notificationUrl', Expected."Notification URL");
        Session.LogMessage('INT0001', 'External event subscription missing', Verbosity::Warning,
            DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, Dimensions);
        // ... and raise an operational alert (email, Teams, ticket) so a human acts before the gap grows.
    end;

    local procedure SubscriptionKey(EventName: Text; NotificationUrl: Text): Text
    begin
        exit(StrSubstNo('%1|%2', EventName, NotificationUrl));
    end;
}
