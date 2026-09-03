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

    trigger OnModify()
    begin
        // Dead branch under any code-driven Modify: from code xRec mirrors Rec, so
        // the two Status values are always equal and LogStatusChange never runs.
        // Editing the field on a page DOES populate xRec, so this passes manual
        // testing and then silently does nothing in a job queue or API call.
        if Status <> xRec.Status then
            LogStatusChange(xRec.Status, Status);
    end;

    local procedure LogStatusChange(FromStatus: Enum "Service Request Status"; ToStatus: Enum "Service Request Status")
    begin
    end;
}
