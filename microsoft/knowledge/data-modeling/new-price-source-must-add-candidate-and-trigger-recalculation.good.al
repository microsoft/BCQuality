tableextension 50105 "Sample Sales Line Ext" extends "Sales Line"
{
    fields
    {
        field(50100; "Sample Loyalty Customer No."; Code[20])
        {
            Caption = 'Sample Loyalty Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            begin
                // Second half of the wiring: without this call, changing
                // the field on an existing line never re-runs price
                // calculation, even though the source is already a known
                // candidate via OnAfterAddSources below.
                //
                // UpdateUnitPriceByField(CalledByFieldNo) only recalculates
                // if PlanPriceCalcByField(CalledByFieldNo) was already
                // called for that same field - calling it alone is a
                // silent no-op. UpdateUnitPrice(CalledByFieldNo) does both
                // steps in the right order (plan, then update) in one
                // call; it's the same method the base app itself calls
                // from outside Sales Line to trigger recalculation for a
                // field it just changed.
                UpdateUnitPrice(FieldNo("Sample Loyalty Customer No."));
            end;
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
