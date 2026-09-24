enumextension 50102 "Sample Price Calc Handler Ext" extends "Price Calculation Handler"
{
    value(50102; "Sample Special Price")
    {
        Caption = 'Sample Special Price';
        Implementation = "Price Calculation" = "Sample Price Calc - Special";
    }
}

// Demonstration-only AL: every method below is stubbed. This article is
// about activating a handler through OnFindSupportedSetup, not about the
// "Price Calculation" interface's own pricing logic.
codeunit 50103 "Sample Price Calc - Special" implements "Price Calculation"
{
    procedure Init(LineWithPrice: Interface "Line With Price"; PriceCalculationSetup: Record "Price Calculation Setup")
    begin
    end;

    procedure GetLine(var Line: Variant)
    begin
    end;

    procedure ApplyDiscount()
    begin
    end;

    procedure ApplyPrice(CalledByFieldNo: Integer)
    begin
    end;

    procedure CountDiscount(ShowAll: Boolean) Result: Integer
    begin
    end;

    procedure CountPrice(ShowAll: Boolean) Result: Integer
    begin
    end;

    procedure FindDiscount(var TempPriceListLine: Record "Price List Line"; ShowAll: Boolean) Found: Boolean
    begin
    end;

    procedure FindPrice(var TempPriceListLine: Record "Price List Line"; ShowAll: Boolean) Found: Boolean
    begin
    end;

    procedure IsDiscountExists(ShowAll: Boolean) Result: Boolean
    begin
    end;

    procedure IsPriceExists(ShowAll: Boolean) Result: Boolean
    begin
    end;

    procedure PickDiscount()
    begin
    end;

    procedure PickPrice()
    begin
    end;

    procedure ShowPrices(var TempPriceListLine: Record "Price List Line")
    begin
    end;
}

codeunit 50104 "Sample Price Calc Setup Install"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Price Calculation Mgt.", 'OnFindSupportedSetup', '', false, false)]
    local procedure AddSampleSpecialPriceSetup(var TempPriceCalculationSetup: Record "Price Calculation Setup" temporary)
    begin
        TempPriceCalculationSetup.Init();
        TempPriceCalculationSetup.Code := 'SAMPLE-SPECIAL';
        TempPriceCalculationSetup.Method := TempPriceCalculationSetup.Method::"Lowest Price";
        TempPriceCalculationSetup.Type := TempPriceCalculationSetup.Type::Sale;
        TempPriceCalculationSetup."Asset Type" := TempPriceCalculationSetup."Asset Type"::" ";
        TempPriceCalculationSetup.Implementation := TempPriceCalculationSetup.Implementation::"Sample Special Price";
        TempPriceCalculationSetup.Enabled := true;
        // Default := true here because this row is meant as the fallback
        // for Method = Lowest Price / Type = Sale / Asset Type = " " (all)
        // - the combination Price Calculation Mgt.'s FindSetup selects via
        // its own SetRange(Default, true) branch when no "Dtld. Price
        // Calculation Setup" row names a more specific match. A handler
        // meant to be picked only through such a specific, explicit
        // detailed-setup row would not need Default := true at all.
        TempPriceCalculationSetup.Default := true;
        TempPriceCalculationSetup.Insert();
    end;
}
