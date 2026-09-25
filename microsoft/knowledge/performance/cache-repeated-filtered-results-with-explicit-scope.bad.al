codeunit 50363 "Perf Variant Cache Bad"
{
    procedure CountLinesWithVariants(OrderNo: Code[20]) VariantLines: Integer
    var
        SalesLine: Record "Sales Line";
        ItemVariant: Record "Item Variant";
    begin
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", OrderNo);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                ItemVariant.SetRange("Item No.", SalesLine."No.");
                if not ItemVariant.IsEmpty() then
                    VariantLines += 1;
            until SalesLine.Next() = 0;
    end;
}
