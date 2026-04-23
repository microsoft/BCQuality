codeunit 51200 "Perf Sample GuardBeforeGet Good"
{
    procedure HandleLine(var PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // Cheap in-memory check first. Get only when the subsequent code needs the header.
        if PurchaseLine."Selected Alloc. Account No." = '' then
            exit;

        if not PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then
            exit;

        // Work with PurchaseHeader.
    end;
}
