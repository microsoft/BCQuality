codeunit 50100 "SCM Stock Adjustment Bad"
{
    procedure PostPreparedPositiveAdjustment(ItemJournalLine: Record "Item Journal Line"; NewEntryNo: Integer)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemJournalLine.TestField("Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.");
        ItemJournalLine.TestField("Value Entry Type", ItemJournalLine."Value Entry Type"::"Direct Cost");
        ItemJournalLine.TestField("Item No.");
        ItemJournalLine.TestField("Posting Date");
        ItemJournalLine.TestField("Quantity (Base)");
        if ItemJournalLine."Quantity (Base)" < 0 then
            Error(PositiveQuantityErr);

        ItemLedgerEntry.Init();
        ItemLedgerEntry."Entry No." := NewEntryNo;
        ItemLedgerEntry."Item No." := ItemJournalLine."Item No.";
        ItemLedgerEntry."Entry Type" := ItemJournalLine."Entry Type";
        ItemLedgerEntry."Posting Date" := ItemJournalLine."Posting Date";
        ItemLedgerEntry."Document No." := ItemJournalLine."Document No.";
        ItemLedgerEntry."Location Code" := ItemJournalLine."Location Code";
        ItemLedgerEntry."Variant Code" := ItemJournalLine."Variant Code";
        ItemLedgerEntry.Quantity := ItemJournalLine."Quantity (Base)";
        ItemLedgerEntry."Remaining Quantity" := ItemLedgerEntry.Quantity;
        ItemLedgerEntry.Positive := true;
        ItemLedgerEntry.Open := true;
        ItemLedgerEntry.Insert(true);
    end;

    var
        PositiveQuantityErr: Label 'The prepared adjustment must increase inventory.';
}
