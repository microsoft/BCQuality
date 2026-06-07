// Best practice: one framing record per feed. It remembers where the last run stopped,
// caps how much one run pulls, and carries a lock with a stale timeout so two overlapping
// Job Queue runs can never fetch the same window.

table 50130 "Inbound Feed Frame"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Feed Code"; Code[20]) { Caption = 'Feed Code'; }
        // The watermark: the next run starts here, so no run ever re-pulls old data.
        field(2; "Last Fetch At"; DateTime) { Caption = 'Last Fetch At'; }
        // The cap: a long-quiet feed catches up over several bounded runs instead of one huge pull.
        field(3; "Max Window (Hours)"; Integer) { Caption = 'Max Window (Hours)'; }
        // Opaque continuation token from the source's paged API, when it offers one.
        field(4; "Cursor"; Text[250]) { Caption = 'Cursor'; }
        // The lock: a second concurrent run sees this set and backs off.
        field(5; "Locked"; Boolean) { Caption = 'Locked'; }
        // Stamped when the lock is taken, so a crashed run's lock can be reclaimed after a timeout.
        field(6; "Locked At"; DateTime) { Caption = 'Locked At'; }
    }

    keys { key(PK; "Feed Code") { Clustered = true; } }
}

codeunit 50131 "Inbound Poller"
{
    TableNo = "Job Queue Entry";

    procedure Poll(FeedCode: Code[20])
    var
        Frame: Record "Inbound Feed Frame";
        WindowEnd: DateTime;
    begin
        Frame.Get(FeedCode);

        // Acquire the lock first. If another run already owns this feed, exit quietly:
        // overlap is the whole problem we are preventing.
        if not TryAcquireLock(Frame) then
            exit;

        // Bounded incremental window: from the watermark up to a capped end. Never "fetch all".
        WindowEnd := CapWindow(Frame."Last Fetch At", Frame."Max Window (Hours)");
        FetchAndStage(Frame, Frame."Last Fetch At", WindowEnd);

        // Advance the watermark and cursor so the NEXT run starts exactly where this one ended.
        // Sequential runs therefore never overlap their windows.
        Frame."Last Fetch At" := WindowEnd;
        Frame."Cursor" := NextCursor();
        ReleaseLock(Frame);
    end;

    local procedure TryAcquireLock(var Frame: Record "Inbound Feed Frame"): Boolean
    begin
        // If the lock is held AND fresh, someone is actively polling: do not steal it.
        if Frame."Locked" and (CurrentDateTime() - Frame."Locked At" < GetStaleTimeoutMs()) then
            exit(false);

        // Either free, or stale (a previous run crashed without releasing). Reclaim it.
        Frame."Locked" := true;
        Frame."Locked At" := CurrentDateTime();
        Frame.Modify(true);
        Commit(); // make the lock durable before the long fetch starts
        exit(true);
    end;

    local procedure ReleaseLock(var Frame: Record "Inbound Feed Frame")
    begin
        Frame."Locked" := false;
        Frame.Modify(true);
    end;

    local procedure GetStaleTimeoutMs(): Integer
    begin
        exit(300000); // 5 minutes: longer than a healthy run, short enough to recover from a crash
    end;
}
