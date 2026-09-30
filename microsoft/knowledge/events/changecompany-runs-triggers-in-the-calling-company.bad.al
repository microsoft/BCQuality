codeunit 50100 "Transfer Request Bad"
{
    // Self-contained demonstration of the anti pattern. Not derived from base-app source.
    procedure RequestFromCompany(TargetCompany: Text[30]; ItemNo: Code[20]; Quantity: Decimal)
    var
        TransferRequest: Record "Transfer Request Bad";
        TransferSetup: Record "Transfer Setup Bad";
    begin
        TransferRequest.ChangeCompany(TargetCompany);
        TransferSetup.ChangeCompany(TargetCompany);
        TransferSetup.Get();

        TransferRequest.Init();
        TransferRequest."Entry No." := NextEntryNo(TargetCompany);
        TransferRequest."Item No." := ItemNo;
        TransferRequest.Quantity := Quantity;
        // OnInsert is skipped below, so the default is copied by hand from the target company's setup.
        TransferRequest."Location Code" := TransferSetup."Default Location Code";
        // The OnAfterInsertEvent subscriber still fires, in the calling company, and grows the caller's counter.
        TransferRequest.Insert(false);

        TransferSetup."Open Requests" += 1;
        TransferSetup.Modify();
    end;

    local procedure NextEntryNo(TargetCompany: Text[30]): Integer
    var
        LastRequest: Record "Transfer Request Bad";
    begin
        LastRequest.ChangeCompany(TargetCompany);
        if LastRequest.FindLast() then
            exit(LastRequest."Entry No." + 1);
        exit(1);
    end;
}

table 50100 "Transfer Request Bad"
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
        TransferSetup: Record "Transfer Setup Bad";
    begin
        TransferSetup.Get();
        "Location Code" := TransferSetup."Default Location Code";
    end;
}

table 50101 "Transfer Setup Bad"
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

codeunit 50101 "Transfer Request Count Bad"
{
    [EventSubscriber(ObjectType::Table, Database::"Transfer Request Bad", OnAfterInsertEvent, '', false, false)]
    local procedure CountOpenRequest(var Rec: Record "Transfer Request Bad"; RunTrigger: Boolean)
    var
        TransferSetup: Record "Transfer Setup Bad";
    begin
        TransferSetup.Get();
        TransferSetup."Open Requests" += 1;
        TransferSetup.Modify();
    end;
}
