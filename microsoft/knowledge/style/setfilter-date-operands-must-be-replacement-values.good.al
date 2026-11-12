codeunit 50170 "Price Validity Filter Good"
{
    procedure FilterValidOn(var PriceListLine: Record "Price List Line"; ReferenceDate: Date)
    begin
        PriceListLine.SetRange("Starting Date", 0D, ReferenceDate);
        PriceListLine.SetFilter("Ending Date", '%1|>=%2', 0D, ReferenceDate);
    end;

    procedure FilterEndingSinceCutover(var PriceListLine: Record "Price List Line")
    begin
        PriceListLine.SetFilter("Ending Date", '%1..', 20261029D);
    end;
}
