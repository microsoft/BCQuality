codeunit 50101 "SCM Stock Adjustment Good"
{
    procedure PostPreparedPositiveAdjustment(var ItemJournalLine: Record "Item Journal Line")
    var
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        ItemJournalLine.TestField("Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.");
        ItemJournalLine.TestField("Value Entry Type", ItemJournalLine."Value Entry Type"::"Direct Cost");
        ItemJournalLine.TestField("Item No.");
        ItemJournalLine.TestField("Posting Date");
        ItemJournalLine.TestField("Quantity (Base)");
        if ItemJournalLine."Quantity (Base)" < 0 then
            Error(PositiveQuantityErr);

        ItemJnlPostLine.RunWithCheck(ItemJournalLine);
    end;

    var
        PositiveQuantityErr: Label 'The prepared adjustment must increase inventory.';
}
