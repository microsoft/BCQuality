codeunit 50104 "SCM Item Application Bad"
{
    procedure ChangeSalesQuantityApplication(ApplicationEntryNo: Integer; NewInboundEntryNo: Integer)
    var
        ItemApplicationEntry: Record "Item Application Entry";
        OutboundItemLedgerEntry: Record "Item Ledger Entry";
        InboundItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemApplicationEntry.Get(ApplicationEntryNo);
        ItemApplicationEntry.TestField(Quantity);
        ItemApplicationEntry.TestField("Inbound Item Entry No.");
        ItemApplicationEntry.TestField("Outbound Item Entry No.");
        ItemApplicationEntry.TestField("Transferred-from Entry No.", 0);
        if ItemApplicationEntry.CostApplication() then
            Error(QuantityApplicationErr);
        OutboundItemLedgerEntry.Get(ItemApplicationEntry."Outbound Item Entry No.");
        OutboundItemLedgerEntry.TestField("Entry Type", OutboundItemLedgerEntry."Entry Type"::Sale);
        OutboundItemLedgerEntry.TestField(Positive, false);
        OutboundItemLedgerEntry.TestField("Drop Shipment", false);
        OutboundItemLedgerEntry.TestField(Correction, false);
        InboundItemLedgerEntry.Get(NewInboundEntryNo);
        InboundItemLedgerEntry.TestField(Positive, true);
        InboundItemLedgerEntry.TestField("Item No.", OutboundItemLedgerEntry."Item No.");
        InboundItemLedgerEntry.TestField("Variant Code", OutboundItemLedgerEntry."Variant Code");
        InboundItemLedgerEntry.TestField("Location Code", OutboundItemLedgerEntry."Location Code");

        ItemApplicationEntry."Inbound Item Entry No." := NewInboundEntryNo;
        ItemApplicationEntry.Modify(true);
    end;

    var
        QuantityApplicationErr: Label 'Select an ordinary quantity application, not a cost application.';
}
