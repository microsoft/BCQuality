codeunit 50171 "Price Validity Filter Bad"
{
    procedure FilterValidOn(var PriceListLine: Record "Price List Line"; ReferenceDate: Date)
    begin
        PriceListLine.SetRange("Starting Date", 0D, ReferenceDate);
        PriceListLine.SetFilter("Ending Date", '0D|>=%1', ReferenceDate);
    end;

    procedure FilterEndingSinceCutover(var PriceListLine: Record "Price List Line")
    begin
        PriceListLine.SetFilter("Ending Date", '29-10-2026..');
    end;
}
