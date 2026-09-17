codeunit 50102 "SCM Revaluation Batch Bad"
{
    procedure PostCalculatedRevaluationBatch(TemplateName: Code[10]; BatchName: Code[10])
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        ItemJournalLine.SetRange("Journal Template Name", TemplateName);
        ItemJournalLine.SetRange("Journal Batch Name", BatchName);
        ItemJournalLine.FindSet();
        repeat
            ItemJournalLine.TestField("Value Entry Type", ItemJournalLine."Value Entry Type"::Revaluation);
            ItemJournalLine.TestField("Inventory Value Per");
            ItemJnlPostLine.RunWithCheck(ItemJournalLine);
        until ItemJournalLine.Next() = 0;
    end;
}
