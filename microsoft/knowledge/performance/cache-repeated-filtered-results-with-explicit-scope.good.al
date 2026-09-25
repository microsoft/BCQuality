codeunit 50363 "Perf Variant Cache Good"
{
    procedure CountLinesWithVariants(OrderNo: Code[20]) VariantLines: Integer
    var
        SalesLine: Record "Sales Line";
        ItemVariant: Record "Item Variant";
        HasVariantsByItem: Dictionary of [Code[20], Boolean];
        HasVariants: Boolean;
    begin
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", OrderNo);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                if not HasVariantsByItem.Get(SalesLine."No.", HasVariants) then begin
                    ItemVariant.SetRange("Item No.", SalesLine."No.");
                    HasVariants := not ItemVariant.IsEmpty();
                    HasVariantsByItem.Add(SalesLine."No.", HasVariants);
                end;
                if HasVariants then
                    VariantLines += 1;
            until SalesLine.Next() = 0;
    end;
}
