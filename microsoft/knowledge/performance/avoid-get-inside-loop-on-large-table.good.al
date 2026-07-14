query 50252 "Perf Sample BOM Cost"
{
    QueryType = Normal;

    elements
    {
        dataitem(ProductionBOMLine; "Production BOM Line")
        {
            column(ProductionBOMNo; "Production BOM No.") { }
            column(VersionCode; "Version Code") { }
            column(QuantityPer; "Quantity per") { }

            dataitem(Item; Item)
            {
                DataItemLink = "No." = ProductionBOMLine."No.";
                DataItemTableFilter = "Costing Method" = const(Standard);
                SqlJoinType = InnerJoin;

                column(StandardCost; "Standard Cost") { }
            }
        }
    }
}

codeunit 50254 "Perf Sample NPlus1 Good"
{
    procedure SumStdCost(BOMNo: Code[20]; BOMVersionCode: Code[20]) TotalCost: Decimal
    var
        BOMCost: Query "Perf Sample BOM Cost";
    begin
        BOMCost.SetRange(ProductionBOMNo, BOMNo);
        BOMCost.SetRange(VersionCode, BOMVersionCode);
        BOMCost.Open();
        while BOMCost.Read() do
            TotalCost += BOMCost.StandardCost * BOMCost.QuantityPer;
        BOMCost.Close();
    end;
}
