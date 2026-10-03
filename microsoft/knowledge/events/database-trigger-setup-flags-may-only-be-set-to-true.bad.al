codeunit 50110 "Change Tracking Subscr. Bad"
{
    // Self-contained demonstration of the anti pattern. Not derived from base-app source.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterGetDatabaseTableTriggerSetup, '', false, false)]
    local procedure OptInTrackedTables(TableId: Integer; var OnDatabaseInsert: Boolean; var OnDatabaseModify: Boolean; var OnDatabaseDelete: Boolean; var OnDatabaseRename: Boolean)
    var
        TrackedTable: Record "Tracked Table Bad";
        IsTracked: Boolean;
    begin
        IsTracked := TrackedTable.Get(TableId);
        // Stores false for every table this feature does not track, clearing flags that
        // Dataverse integration, API webhooks, or another app already set for that table.
        OnDatabaseModify := IsTracked;
        OnDatabaseDelete := IsTracked;
        // Opting out of operations this feature does not need clears them for everyone else too.
        OnDatabaseInsert := false;
        OnDatabaseRename := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterOnDatabaseModify, '', false, false)]
    local procedure LogModify(RecRef: RecordRef)
    var
        TrackedChange: Record "Tracked Change Bad";
    begin
        TrackedChange.Init();
        TrackedChange."Table No." := RecRef.Number();
        TrackedChange."Record ID" := RecRef.RecordId();
        TrackedChange.Insert();
    end;
}

table 50110 "Tracked Table Bad"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Table No."; Integer) { }
    }

    keys
    {
        key(PK; "Table No.") { Clustered = true; }
    }
}

table 50111 "Tracked Change Bad"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer) { AutoIncrement = true; }
        field(2; "Table No."; Integer) { }
        field(3; "Record ID"; RecordId) { }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}
