codeunit 50112 "SCM Transfer Posting Bad"
{
    procedure ShipTransferOrder(TransferOrderNo: Code[20]; var ItemJournalLine: Record "Item Journal Line")
    var
        TransferHeader: Record "Transfer Header";
        Location: Record Location;
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        TransferHeader.Get(TransferOrderNo);
        TransferHeader.TestField("Direct Transfer", false);
        TransferHeader.TestField("In-Transit Code");
        Location.Get(TransferHeader."Transfer-from Code");
        Location.TestField("Require Shipment", false);
        ItemJournalLine.TestField("Entry Type", ItemJournalLine."Entry Type"::Transfer);
        ItemJournalLine.TestField("Location Code", TransferHeader."Transfer-from Code");
        ItemJournalLine.TestField("New Location Code", TransferHeader."In-Transit Code");

        ItemJnlPostLine.RunWithCheck(ItemJournalLine);
        TransferHeader."Last Shipment No." := ItemJournalLine."Document No.";
        TransferHeader.Modify(true);
    end;
}
