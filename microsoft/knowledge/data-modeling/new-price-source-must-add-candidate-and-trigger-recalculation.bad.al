tableextension 50105 "Sample Sales Line Ext" extends "Sales Line"
{
    fields
    {
        // WRONG: no OnValidate trigger. The field is registered as a
        // price source below via OnAfterAddSources, so new lines price
        // correctly - but changing this field on an existing line never
        // triggers a recalculation (e.g. via UpdateUnitPrice), so the
        // unit price silently keeps its old value.
        field(50100; "Sample Loyalty Customer No."; Code[20])
        {
            Caption = 'Sample Loyalty Customer No.';
            TableRelation = Customer;
        }
    }
}

codeunit 50106 "Sample Sales Line Price Sources"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Line - Price", 'OnAfterAddSources', '', false, false)]
    local procedure AddLoyaltyCustomerSource(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; PriceType: Enum "Price Type"; var PriceSourceList: Codeunit "Price Source List")
    begin
        PriceSourceList.Add(Enum::"Price Source Type"::Customer, SalesLine."Sample Loyalty Customer No.");
    end;
}
