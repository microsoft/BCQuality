table 50224 "Dispatch Receipt Sample"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { }
        field(2; "Receipt Id"; Guid) { }
        field(3; Completed; Boolean) { }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}

codeunit 50225 "Dispatch Completion Good"
{
    procedure CompleteDispatch(EntryNo: Integer; ReceiptId: Guid; StartDate: Date; EndDate: Date)
    var
        DispatchReceipt: Record "Dispatch Receipt Sample";
    begin
        ValidateWindow(StartDate, EndDate);
        if IsNullGuid(ReceiptId) then
            Error(MissingReceiptErr);
        DispatchReceipt.Get(EntryNo);
        DispatchReceipt.TestField(Completed, false);
        DispatchReceipt."Receipt Id" := ReceiptId;
        DispatchReceipt.Completed := true;
        DispatchReceipt.Modify(true);
        OnAfterDispatchCompleted(EntryNo, ReceiptId);
    end;

    local procedure ValidateWindow(StartDate: Date; EndDate: Date)
    begin
        if EndDate < StartDate then
            Error(InvalidWindowErr);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDispatchCompleted(EntryNo: Integer; ReceiptId: Guid)
    begin
    end;

    var
        MissingReceiptErr: Label 'A dispatch receipt is required.';
        InvalidWindowErr: Label 'The end date must not precede the start date.';
}
