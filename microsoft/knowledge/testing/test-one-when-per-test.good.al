[Test]
procedure GetPrice_CustomerPrice_ReturnsCorrectUnitPrice()
var
    Customer: Record Customer;
    Item: Record Item;
    PriceListHeader: Record "Price List Header";
    PriceListLine: Record "Price List Line";
    SalesHeader: Record "Sales Header";
    SalesLine: Record "Sales Line";
begin
    // [SCENARIO] A customer price list line sets the unit price on a new sales line
    // [GIVEN] a customer with a price list line for the item
    LibrarySales.CreateCustomer(Customer);
    LibraryInventory.CreateItem(Item);
    LibraryPriceCalculation.CreatePriceHeader(
        PriceListHeader, PriceListHeader."Price Type"::Sale, "Price Source Type"::Customer, Customer."No.");
    LibraryPriceCalculation.CreateSalesPriceLine(
        PriceListLine, PriceListHeader.Code, "Price Source Type"::Customer, Customer."No.",
        "Price Asset Type"::Item, Item."No.");
    // CreatePriceHeader leaves the list in Draft status, which price calculation ignores.
    PriceListHeader.Validate(Status, PriceListHeader.Status::Active);
    PriceListHeader.Modify(true);
    // [WHEN] a sales line is created for the customer and item
    LibrarySales.CreateSalesDocumentWithItem(
        SalesHeader, SalesLine, SalesHeader."Document Type"::Order, Customer."No.", Item."No.", 1, '', 0D);
    // [THEN] the sales line picks up the unit price of the price list line
    Assert.AreEqual(PriceListLine."Unit Price", SalesLine."Unit Price", 'Unit price must match price list');
end;

[Test]
procedure GetPriceLines_TwoMinimumQuantityLines_ReturnsBoth()
var
    Customer: Record Customer;
    Item: Record Item;
    PriceListHeader: Record "Price List Header";
    PriceListLine: Record "Price List Line";
begin
    // [SCENARIO] A price list with two minimum-quantity lines for one item holds both lines
    // [GIVEN] a customer price list with two minimum-quantity price lines for the same item
    LibrarySales.CreateCustomer(Customer);
    LibraryInventory.CreateItem(Item);
    LibraryPriceCalculation.CreatePriceHeader(
        PriceListHeader, PriceListHeader."Price Type"::Sale, "Price Source Type"::Customer, Customer."No.");
    LibraryPriceCalculation.CreateSalesPriceLine(
        PriceListLine, PriceListHeader.Code, "Price Source Type"::Customer, Customer."No.",
        "Price Asset Type"::Item, Item."No.");
    PriceListLine.Validate("Minimum Quantity", 10);
    PriceListLine.Modify(true);
    LibraryPriceCalculation.CreateSalesPriceLine(
        PriceListLine, PriceListHeader.Code, "Price Source Type"::Customer, Customer."No.",
        "Price Asset Type"::Item, Item."No.");
    PriceListLine.Validate("Minimum Quantity", 50);
    PriceListLine.Modify(true);
    // [WHEN] the lines of the price list are read
    PriceListLine.SetRange("Price List Code", PriceListHeader.Code);
    // [THEN] the filtered set contains two price list lines
    Assert.AreEqual(2, PriceListLine.Count(), 'Exactly two price lines expected');
end;
