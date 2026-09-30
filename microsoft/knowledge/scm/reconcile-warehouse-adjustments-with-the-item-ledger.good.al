codeunit 50111 "SCM Warehouse Adjustment Good"
{
    procedure ReconcileRegisteredWarehouseAdjustment(ItemNo: Code[20]; LocationCode: Code[10]; TemplateName: Code[10]; BatchName: Code[10]; PostingDate: Date; DocumentNo: Code[20]): Boolean
    var
        Item: Record Item;
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        Location: Record Location;
        CalculateWhseAdjustment: Report "Calculate Whse. Adjustment";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
    begin
        Location.Get(LocationCode);
        Location.TestField("Directed Put-away and Pick", true);
        Location.TestField("Adjustment Bin Code");
        ItemJournalBatch.Get(TemplateName, BatchName);
        ItemJournalLine.SetRange("Journal Template Name", TemplateName);
        ItemJournalLine.SetRange("Journal Batch Name", BatchName);
        if not ItemJournalLine.IsEmpty() then
            Error(EmptyBatchErr);

        Item.Get(ItemNo);
        Item.SetRecFilter();
        Item.SetRange("Location Filter", LocationCode);
        ItemJournalLine."Journal Template Name" := TemplateName;
        ItemJournalLine."Journal Batch Name" := BatchName;
        CalculateWhseAdjustment.SetItemJnlLine(ItemJournalLine);
        CalculateWhseAdjustment.SetTableView(Item);
        CalculateWhseAdjustment.InitializeRequest(PostingDate, DocumentNo);
        CalculateWhseAdjustment.SetHideValidationDialog(true);
        CalculateWhseAdjustment.UseRequestPage(false);
        CalculateWhseAdjustment.RunModal();

        if ItemJournalLine.FindFirst() then begin
            ItemJournalLine.TestField("Warehouse Adjustment", true);
            ItemJnlPostBatch.Run(ItemJournalLine);
        end;
        exit(true);
    end;

    var
        EmptyBatchErr: Label 'Use an empty, dedicated item journal batch for warehouse reconciliation.';
}
