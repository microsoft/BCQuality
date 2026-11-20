table 50920 "Receipt Quantity Staging"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Batch ID"; Guid) { }
        field(2; "Receipt Code"; Code[20]) { }
        field(3; Quantity; Decimal) { }
    }

    keys
    {
        key(PK; "Batch ID", "Receipt Code", Quantity) { Clustered = true; }
    }
}

table 50921 "Receipt Quantity Buffer"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Receipt Code"; Code[20]) { }
        field(2; Quantity; Decimal) { }
    }

    keys
    {
        key(PK; "Receipt Code") { Clustered = true; }
    }
}

codeunit 50922 "Receipt Quantity Good"
{
    procedure BuildBatch() BatchId: Guid
    var
        TempBuffer: Record "Receipt Quantity Buffer" temporary;
        Staging: Record "Receipt Quantity Staging";
    begin
        BatchId := CreateGuid();
        AddQuantity(TempBuffer, 'RECEIPT-A', 4);
        AddQuantity(TempBuffer, 'RECEIPT-A', 6);
        AddQuantity(TempBuffer, 'RECEIPT-B', 7);

        if TempBuffer.FindSet() then
            repeat
                Staging.Init();
                Staging."Batch ID" := BatchId;
                Staging."Receipt Code" := TempBuffer."Receipt Code";
                Staging.Quantity := TempBuffer.Quantity;
                Staging.Insert();
            until TempBuffer.Next() = 0;
    end;

    local procedure AddQuantity(var TempBuffer: Record "Receipt Quantity Buffer" temporary; ReceiptCode: Code[20]; IncomingQuantity: Decimal)
    begin
        if TempBuffer.Get(ReceiptCode) then begin
            TempBuffer.Quantity += IncomingQuantity;
            TempBuffer.Modify();
        end else begin
            TempBuffer.Init();
            TempBuffer."Receipt Code" := ReceiptCode;
            TempBuffer.Quantity := IncomingQuantity;
            TempBuffer.Insert();
        end;
    end;

    // Alternative for this staging table, which has no rename restrictions or triggers.
    procedure AddToExistingRow(BatchId: Guid; ReceiptCode: Code[20]; OriginalQuantity: Decimal; IncomingQuantity: Decimal)
    var
        Staging: Record "Receipt Quantity Staging";
        NewQuantity: Decimal;
    begin
        Staging.Get(BatchId, ReceiptCode, OriginalQuantity);
        NewQuantity := Staging.Quantity + IncomingQuantity;
        Staging.Rename(Staging."Batch ID", Staging."Receipt Code", NewQuantity);
    end;
}
