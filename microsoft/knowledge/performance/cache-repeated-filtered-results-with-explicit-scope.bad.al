codeunit 50363 "Perf Variant Cache Bad"
{
    procedure CountAndCollectVariantLines(var TempSalesLine: Record "Sales Line" temporary; OrderNo: Code[20]; var VariantItemNos: List of [Code[20]]) VariantLines: Integer
    var
        ItemVariant: Record "Item Variant";
    begin
        TempSalesLine.SetRange("Document Type", TempSalesLine."Document Type"::Order);
        TempSalesLine.SetRange("Document No.", OrderNo);
        TempSalesLine.SetRange(Type, TempSalesLine.Type::Item);
        if TempSalesLine.FindSet() then
            repeat
                ItemVariant.SetRange("Item No.", TempSalesLine."No.");
                if not ItemVariant.IsEmpty() then
                    VariantLines += 1;
            until TempSalesLine.Next() = 0;

        if TempSalesLine.FindSet() then
            repeat
                ItemVariant.SetRange("Item No.", TempSalesLine."No.");
                if not ItemVariant.IsEmpty() then
                    VariantItemNos.Add(TempSalesLine."No.");
            until TempSalesLine.Next() = 0;
    end;
}
