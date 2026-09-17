codeunit 50253 "Perf Sample NPlus1 Bad"
{
    procedure SumStdCost(BOMNo: Code[20]; BOMVersionCode: Code[20]) TotalCost: Decimal
    var
        BOMLine: Record "Production BOM Line";
        Item: Record Item;
    begin
        BOMLine.SetRange("Production BOM No.", BOMNo);
        BOMLine.SetRange("Version Code", BOMVersionCode);
        if BOMLine.FindSet() then
            repeat
                if Item.Get(BOMLine."No.") then
                    if Item."Costing Method" = Item."Costing Method"::Standard then
                        TotalCost += Item."Standard Cost" * BOMLine."Quantity per";
            until BOMLine.Next() = 0;
    end;
}
