// Demonstration only; independently authored, not copied from BaseApp.
codeunit 50641 "Sales Doc. VAT Basis Bad"
{
    procedure GetNetAndGrossTotals(SalesHeader: Record "Sales Header"; var NetTotal: Decimal; var GrossTotal: Decimal)
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                // Wrong: "Line Amount" already includes VAT when the header has Prices Including VAT,
                // so NetTotal is gross and VAT is added a second time. Invoice discount is also ignored.
                NetTotal += SalesLine."Line Amount";
                GrossTotal += SalesLine."Line Amount" * (1 + SalesLine."VAT %" / 100);
            until SalesLine.Next() = 0;
    end;

    procedure GetOutstandingNetAmount(SalesLine: Record "Sales Line"): Decimal
    begin
        // Wrong: despite its name, CalculateOutstandingAmountExclTax is based on "Line Amount"
        // and therefore includes VAT on a Prices Including VAT document.
        exit(SalesLine.CalculateOutstandingAmountExclTax());
    end;

    procedure SetUnitPriceFromNetSourcePrice(var SalesLine: Record "Sales Line"; NetSourcePrice: Decimal)
    begin
        // Wrong: on a Prices Including VAT document this net price is read as a gross price,
        // so the net line amount drops to NetSourcePrice / (1 + "VAT %" / 100).
        SalesLine.Validate("Unit Price", NetSourcePrice);
        SalesLine.Modify(true);
    end;
}
