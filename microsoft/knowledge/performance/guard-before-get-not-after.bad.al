codeunit 51201 "Perf Sample GuardBeforeGet Bad"
{
    procedure HandleLine(var PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // Get fires on every call — including the ones that exit immediately below.
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");

        if PurchaseLine."Selected Alloc. Account No." = '' then
            exit;

        // Work with PurchaseHeader.
    end;
}
