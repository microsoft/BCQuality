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
    // [SCENARIO] Customer price list lines apply to a sales line for the customer and item
    // [GIVEN] a customer and an item with a customer price list line
    LibrarySales.CreateCustomer(Customer);
    LibraryInventory.CreateItem(Item);
    LibraryPriceCalculation.CreatePriceHeader(
        PriceListHeader, PriceListHeader."Price Type"::Sale, "Price Source Type"::Customer, Customer."No.");
    LibraryPriceCalculation.CreateSalesPriceLine(
        PriceListLine, PriceListHeader.Code, "Price Source Type"::Customer, Customer."No.",
        "Price Asset Type"::Item, Item."No.");
    // [WHEN] a sales line is created for the customer and item
    LibrarySales.CreateSalesDocumentWithItem(
        SalesHeader, SalesLine, SalesHeader."Document Type"::Order, Customer."No.", Item."No.", 1, '', 0D);
    // [WHEN] the price list line gets a minimum quantity of 10 and another price list line is created
    // This second action is a second test in disguise.
    PriceListLine.Validate("Minimum Quantity", 10);
    PriceListLine.Modify(true);
    LibraryPriceCalculation.CreateSalesPriceLine(
        PriceListLine, PriceListHeader.Code, "Price Source Type"::Customer, Customer."No.",
        "Price Asset Type"::Item, Item."No.");
    // [THEN] the sales line unit price matches the price list line and the price list holds two lines
    // These assertions cover two unrelated things.
    Assert.AreEqual(PriceListLine."Unit Price", SalesLine."Unit Price", '');
    PriceListLine.SetRange("Price List Code", PriceListHeader.Code);
    Assert.AreEqual(2, PriceListLine.Count(), '');
end;
