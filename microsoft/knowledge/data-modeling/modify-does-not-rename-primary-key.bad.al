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

codeunit 50922 "Receipt Quantity Bad"
{
    procedure BuildBatch() BatchId: Guid
    var
        Staging: Record "Receipt Quantity Staging";
    begin
        BatchId := CreateGuid();
        Staging.Init();
        Staging."Batch ID" := BatchId;
        Staging."Receipt Code" := 'RECEIPT-A';
        Staging.Quantity := 4;
        Staging.Insert();

        Staging.Get(BatchId, 'RECEIPT-A', 4);
        Staging.Quantity += 6;
        Staging.Modify();
    end;
}
