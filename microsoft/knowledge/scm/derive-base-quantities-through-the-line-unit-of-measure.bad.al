codeunit 50181 "Scanner Receipt Import Bad"
{
    procedure PostScannedReceipt(ItemNo: Code[20]; LocationCode: Code[10]; UnitOfMeasureCode: Code[10]; ScannedQuantity: Decimal; DocumentNo: Code[20])
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        if ScannedQuantity <= 0 then
            Error(PositiveQuantityErr);

        ItemJournalLine.Init();
        ItemJournalLine.Validate("Posting Date", WorkDate());
        ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.");
        ItemJournalLine.Validate("Document No.", DocumentNo);
        ItemJournalLine.Validate("Item No.", ItemNo);
        ItemJournalLine.Validate("Location Code", LocationCode);
        ItemJournalLine."Unit of Measure Code" := UnitOfMeasureCode;
        ItemJournalLine.Quantity := ScannedQuantity;
        ItemJournalLine."Quantity (Base)" := ScannedQuantity;

        ItemJnlPostLine.RunWithCheck(ItemJournalLine);
    end;

    var
        PositiveQuantityErr: Label 'The scanned quantity must be greater than zero.';
}
