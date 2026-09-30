// Demonstration only; independently authored, not copied from BaseApp.
codeunit 50640 "Sales Doc. VAT Basis Good"
{
    procedure GetNetAndGrossTotals(SalesHeader: Record "Sales Header"; var NetTotal: Decimal; var GrossTotal: Decimal)
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        // Amount is always net and "Amount Including VAT" always gross, after line and
        // invoice discounts, whatever the header's "Prices Including VAT" says.
        SalesLine.CalcSums(Amount, "Amount Including VAT");
        NetTotal := SalesLine.Amount;
        GrossTotal := SalesLine."Amount Including VAT";
    end;

    procedure SetUnitPriceFromNetSourcePrice(var SalesLine: Record "Sales Line"; NetSourcePrice: Decimal)
    var
        SalesHeader: Record "Sales Header";
        Currency: Record Currency;
        UnitPrice: Decimal;
    begin
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        // Scope of the conversion below: Normal VAT only; Full VAT and Sales Tax need their own handling.
        SalesLine.TestField("VAT Calculation Type", SalesLine."VAT Calculation Type"::"Normal VAT");
        Currency.Initialize(SalesHeader."Currency Code");

        UnitPrice := NetSourcePrice;
        // "Unit Price" is gross on a Prices Including VAT document: convert the net source price into that basis.
        if SalesHeader."Prices Including VAT" then
            UnitPrice := Round(NetSourcePrice * (1 + SalesLine."VAT %" / 100), Currency."Unit-Amount Rounding Precision");

        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Modify(true);
    end;
}
