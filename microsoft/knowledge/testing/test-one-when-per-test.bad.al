[Test]
procedure GetPrice_ThenGetPriceLines_ReturnsCorrectValues()
var
    Customer: Record Customer;
    Item: Record Item;
    PriceListHeader: Record "Price List Header";
    PriceListLine: Record "Price List Line";
    SalesHeader: Record "Sales Header";
    SalesLine: Record "Sales Line";
begin
    // [GIVEN] ...
    LibrarySales.CreateCustomer(Customer);
    LibraryInventory.CreateItem(Item);
    LibraryPriceCalculation.CreatePriceHeader(
        PriceListHeader, PriceListHeader."Price Type"::Sale, "Price Source Type"::Customer, Customer."No.");
    LibraryPriceCalculation.CreateSalesPriceLine(
        PriceListLine, PriceListHeader.Code, "Price Source Type"::Customer, Customer."No.",
        "Price Asset Type"::Item, Item."No.");
    // [WHEN] first action
    LibrarySales.CreateSalesDocumentWithItem(
        SalesHeader, SalesLine, SalesHeader."Document Type"::Order, Customer."No.", Item."No.", 1, '', 0D);
    // [WHEN] second action — this is a second test in disguise
    PriceListLine.Validate("Minimum Quantity", 10);
    PriceListLine.Modify(true);
    LibraryPriceCalculation.CreateSalesPriceLine(
        PriceListLine, PriceListHeader.Code, "Price Source Type"::Customer, Customer."No.",
        "Price Asset Type"::Item, Item."No.");
    // [THEN] asserting two unrelated things
    Assert.AreEqual(PriceListLine."Unit Price", SalesLine."Unit Price", '');
    PriceListLine.SetRange("Price List Code", PriceListHeader.Code);
    Assert.AreEqual(2, PriceListLine.Count(), '');
end;
