codeunit 50543 "Perf Sample CaseChain Bad"
{
    procedure IsShippableLine(SalesLine: Record "Sales Line"): Boolean
    var
        Item: Record Item;
    begin
        // Five levels of nesting to sequence five guards. The evaluation order is
        // carried by indentation alone and the body drifts steadily right.
        if SalesLine.Type = SalesLine.Type::Item then
            if SalesLine."No." <> '' then
                if SalesLine."Qty. to Ship" > 0 then
                    if Item.Get(SalesLine."No.") then
                        if not Item.Blocked then
                            exit(true);
        exit(false);
    end;

    procedure IsShippableLineCollapsed(SalesLine: Record "Sales Line"): Boolean
    var
        Item: Record Item;
    begin
        // The wrong escape from the ladder: flattening it into 'and' trades the
        // nesting for a defect, because every operand is still evaluated. Item
        // fields are read even when the Get failed. The parentheses are not
        // optional either — 'and' binds tighter than '=' and '<>' in AL.
        exit((SalesLine.Type = SalesLine.Type::Item) and (SalesLine."No." <> '') and
             (SalesLine."Qty. to Ship" > 0) and Item.Get(SalesLine."No.") and not Item.Blocked);
    end;
}
