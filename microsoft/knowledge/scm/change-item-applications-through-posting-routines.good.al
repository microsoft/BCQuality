namespace BCQuality.SCM.Samples;

using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Posting;

codeunit 50105 "SCM Item Application Good"
{
    procedure ChangeSalesQuantityApplication(ApplicationEntryNo: Integer; NewInboundEntryNo: Integer)
    var
        ItemApplicationEntry: Record "Item Application Entry";
        OutboundItemLedgerEntry: Record "Item Ledger Entry";
        InboundItemLedgerEntry: Record "Item Ledger Entry";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        OutboundEntryNo: Integer;
    begin
        ItemApplicationEntry.Get(ApplicationEntryNo);
        ItemApplicationEntry.TestField(Quantity);
        ItemApplicationEntry.TestField("Inbound Item Entry No.");
        ItemApplicationEntry.TestField("Outbound Item Entry No.");
        ItemApplicationEntry.TestField("Transferred-from Entry No.", 0);
        if ItemApplicationEntry.CostApplication() then
            Error(QuantityApplicationErr);
        OutboundEntryNo := ItemApplicationEntry."Outbound Item Entry No.";
        OutboundItemLedgerEntry.Get(OutboundEntryNo);
        OutboundItemLedgerEntry.TestField("Entry Type", OutboundItemLedgerEntry."Entry Type"::Sale);
        OutboundItemLedgerEntry.TestField(Positive, false);
        OutboundItemLedgerEntry.TestField("Drop Shipment", false);
        OutboundItemLedgerEntry.TestField(Correction, false);
        InboundItemLedgerEntry.Get(NewInboundEntryNo);
        InboundItemLedgerEntry.TestField(Positive, true);
        InboundItemLedgerEntry.TestField("Item No.", OutboundItemLedgerEntry."Item No.");
        InboundItemLedgerEntry.TestField("Variant Code", OutboundItemLedgerEntry."Variant Code");
        InboundItemLedgerEntry.TestField("Location Code", OutboundItemLedgerEntry."Location Code");

        ItemJnlPostLine.UnApply(ItemApplicationEntry);
        OutboundItemLedgerEntry.Get(OutboundEntryNo);
        ItemJnlPostLine.ReApply(OutboundItemLedgerEntry, NewInboundEntryNo);
        ItemJnlPostLine.RedoApplications();
        ItemJnlPostLine.CostAdjust();
        ItemJnlPostLine.ClearApplicationLog();
    end;

    var
        QuantityApplicationErr: Label 'Select an ordinary quantity application, not a cost application.';
}
