codeunit 50100 "Transfer Request Good"
{
    // Self-contained demonstration of the best practice. Not derived from base-app source.
    procedure RequestFromCompany(TargetCompany: Text[30]; ItemNo: Code[20]; Quantity: Decimal)
    var
        TransferRequest: Record "Transfer Request Good";
        SessionId: Integer;
    begin
        TransferRequest.Init();
        TransferRequest."Item No." := ItemNo;
        TransferRequest.Quantity := Quantity;
        // The insert runs inside TargetCompany, so OnInsert and the subscriber read that company's setup.
        StartSession(SessionId, Codeunit::"Transfer Request Create Good", TargetCompany, TransferRequest);
    end;
}

codeunit 50102 "Transfer Request Create Good"
{
    TableNo = "Transfer Request Good";

    trigger OnRun()
    begin
        Rec."Entry No." := NextEntryNo();
        Rec.Insert(true);
    end;

    local procedure NextEntryNo(): Integer
    var
        LastRequest: Record "Transfer Request Good";
    begin
        if LastRequest.FindLast() then
            exit(LastRequest."Entry No." + 1);
        exit(1);
    end;
}

table 50100 "Transfer Request Good"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { }
        field(2; "Item No."; Code[20]) { }
        field(3; Quantity; Decimal) { }
        field(4; "Location Code"; Code[10]) { }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }

    trigger OnInsert()
    var
        TransferSetup: Record "Transfer Setup Good";
    begin
        TransferSetup.Get();
        "Location Code" := TransferSetup."Default Location Code";
    end;
}

table 50101 "Transfer Setup Good"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10]) { }
        field(2; "Default Location Code"; Code[10]) { }
        field(3; "Open Requests"; Integer) { }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}

codeunit 50101 "Transfer Request Count Good"
{
    [EventSubscriber(ObjectType::Table, Database::"Transfer Request Good", OnAfterInsertEvent, '', false, false)]
    local procedure CountOpenRequest(var Rec: Record "Transfer Request Good"; RunTrigger: Boolean)
    var
        TransferSetup: Record "Transfer Setup Good";
    begin
        TransferSetup.Get();
        TransferSetup."Open Requests" += 1;
        TransferSetup.Modify();
    end;
}
