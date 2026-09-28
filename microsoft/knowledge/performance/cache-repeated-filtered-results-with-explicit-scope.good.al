codeunit 50363 "Perf Variant Cache Good"
{
    procedure CountAndCollectVariantLines(var TempSalesLine: Record "Sales Line" temporary; OrderNo: Code[20]; var VariantItemNos: List of [Code[20]]) VariantLines: Integer
    var
        ItemVariant: Record "Item Variant";
        HasVariantsByItem: Dictionary of [Code[20], Boolean];
    begin
        TempSalesLine.SetRange("Document Type", TempSalesLine."Document Type"::Order);
        TempSalesLine.SetRange("Document No.", OrderNo);
        TempSalesLine.SetRange(Type, TempSalesLine.Type::Item);
        if TempSalesLine.FindSet() then
            repeat
                if HasVariants(TempSalesLine."No.", ItemVariant, HasVariantsByItem) then
                    VariantLines += 1;
            until TempSalesLine.Next() = 0;

        if TempSalesLine.FindSet() then
            repeat
                if HasVariants(TempSalesLine."No.", ItemVariant, HasVariantsByItem) then
                    VariantItemNos.Add(TempSalesLine."No.");
            until TempSalesLine.Next() = 0;
    end;

    local procedure HasVariants(ItemNo: Code[20]; var ItemVariant: Record "Item Variant"; var HasVariantsByItem: Dictionary of [Code[20], Boolean]): Boolean
    var
        CachedResult: Boolean;
    begin
        if HasVariantsByItem.Get(ItemNo, CachedResult) then
            exit(CachedResult);

        ItemVariant.SetRange("Item No.", ItemNo);
        CachedResult := not ItemVariant.IsEmpty();
        HasVariantsByItem.Add(ItemNo, CachedResult);
        exit(CachedResult);
    end;

    procedure CountDistinctItemsWithVariants(var TempItems: Record Item temporary) VariantItems: Integer
    var
        ItemVariant: Record "Item Variant";
    begin
        if TempItems.FindSet() then
            repeat
                ItemVariant.SetRange("Item No.", TempItems."No.");
                if not ItemVariant.IsEmpty() then
                    VariantItems += 1;
            until TempItems.Next() = 0;
    end;
}
