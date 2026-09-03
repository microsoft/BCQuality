table 50130 "Service Request"
{
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(2; Status; Enum "Service Request Status")
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    // OnModify: xRec mirrors Rec when the write came from code, so it cannot be
    // used as a before-image. Re-read the stored row instead — this behaves the
    // same whether a page, a job queue or an API drove the write.
    trigger OnModify()
    var
        Previous: Record "Service Request";
    begin
        if Previous.Get("No.") and (Previous.Status <> Status) then
            LogStatusChange(Previous.Status, Status);
    end;

    // OnRename: xRec IS the before-image of the primary key here, whatever drove
    // the rename. This is the one trigger where the idiom is reliable.
    trigger OnRename()
    begin
        RepointDependents(xRec."No.", "No.");
    end;

    // OnDelete: xRec reflects the record being removed.
    trigger OnDelete()
    begin
        ArchiveRequest(xRec."No.");
    end;

    local procedure LogStatusChange(FromStatus: Enum "Service Request Status"; ToStatus: Enum "Service Request Status")
    begin
    end;

    local procedure RepointDependents(OldNo: Code[20]; NewNo: Code[20])
    begin
    end;

    local procedure ArchiveRequest(RequestNo: Code[20])
    begin
    end;
}
