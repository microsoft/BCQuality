codeunit 50103 "SCM Revaluation Batch Good"
{
    procedure PostCalculatedRevaluationBatch(TemplateName: Code[10]; BatchName: Code[10])
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
    begin
        ItemJournalLine.SetRange("Journal Template Name", TemplateName);
        ItemJournalLine.SetRange("Journal Batch Name", BatchName);
        ItemJournalLine.FindFirst();
        ItemJournalLine.TestField("Value Entry Type", ItemJournalLine."Value Entry Type"::Revaluation);
        ItemJournalLine.TestField("Inventory Value Per");

        ItemJnlPostBatch.Run(ItemJournalLine);
    end;
}
