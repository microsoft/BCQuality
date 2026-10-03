codeunit 50112 "Change Tracking Subscr. Good"
{
    // Self-contained demonstration of the best practice. Not derived from base-app source.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterGetDatabaseTableTriggerSetup, '', false, false)]
    local procedure OptInTrackedTables(TableId: Integer; var OnDatabaseInsert: Boolean; var OnDatabaseModify: Boolean; var OnDatabaseDelete: Boolean; var OnDatabaseRename: Boolean)
    var
        TrackedTable: Record "Tracked Table Good";
    begin
        // Only ever turn flags on; flags set by other features stay untouched.
        if not TrackedTable.Get(TableId) then
            exit;
        OnDatabaseModify := true;
        OnDatabaseDelete := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterOnDatabaseModify, '', false, false)]
    local procedure LogModify(RecRef: RecordRef)
    var
        TrackedTable: Record "Tracked Table Good";
        TrackedChange: Record "Tracked Change Good";
    begin
        // The event also fires for tables other features opted in.
        if RecRef.IsTemporary() then
            exit;
        if not TrackedTable.Get(RecRef.Number()) then
            exit;

        TrackedChange.Init();
        TrackedChange."Table No." := RecRef.Number();
        TrackedChange."Record ID" := RecRef.RecordId();
        TrackedChange.Insert();
    end;
}

table 50112 "Tracked Table Good"
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

table 50113 "Tracked Change Good"
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
