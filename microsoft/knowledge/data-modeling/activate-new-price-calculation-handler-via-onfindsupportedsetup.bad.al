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

// WRONG: no subscriber to Price Calculation Mgt.'s OnFindSupportedSetup.
// "Sample Special Price" is a real, working implementation of the Price
// Calculation interface - it simply has no Price Calculation Setup row
// naming it, so Price Calculation Mgt. never selects it for any sale,
// purchase, or job line, whether through the Default fallback or through
// a "Dtld. Price Calculation Setup" row. It ships invisible until someone
// notices and configures a setup row for it by hand.
