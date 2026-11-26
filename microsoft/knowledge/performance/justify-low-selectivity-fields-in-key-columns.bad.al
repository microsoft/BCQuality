// The process reads every row of one batch, posts it, and marks the batch processed.
// The key leads with a flag the read does not filter, so it cannot seek on "Batch No.",
// while the ModifyAll still maintains the index for every row it changes.
table 50380 "Perf Staging Entry"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { }
        field(2; "Batch No."; Code[20]) { }
        field(3; "Customer No."; Code[20]) { }
        field(4; Amount; Decimal) { }
        field(5; Processed; Boolean) { }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(ByProcessedBatch; Processed, "Batch No.") { }
    }
}

codeunit 50381 "Perf Staging Processor Bad"
{
    procedure ProcessBatch(BatchNo: Code[20])
    var
        Entry: Record "Perf Staging Entry";
    begin
        Entry.SetRange("Batch No.", BatchNo);
        Entry.SetLoadFields("Customer No.", Amount);
        if Entry.FindSet() then
            repeat
                PostAmount(Entry."Customer No.", Entry.Amount);
            until Entry.Next() = 0;
        Entry.ModifyAll(Processed, true);
    end;

    local procedure PostAmount(CustomerNo: Code[20]; Amount: Decimal)
    begin
    end;
}
