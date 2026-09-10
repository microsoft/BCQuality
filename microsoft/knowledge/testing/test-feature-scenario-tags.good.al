// [FEATURE] Item Price — price cascade (Customer -> Price Group -> All Customers)
codeunit 50103 "Item Price Testing"
{
    Subtype = Test;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPriceCalculation: Codeunit "Library - Price Calculation";
        Assert: Codeunit "Library Assert";

    [Test]
    procedure GetPrice_CustomerPrice_ReturnsUnitPrice()
    var
        Customer: Record Customer;
        Item: Record Item;
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [SCENARIO] Customer with a specific price list line gets that unit price
        // [GIVEN] a customer and an item with a customer-specific sales price list line
        LibrarySales.CreateCustomer(Customer);
        LibraryInventory.CreateItem(Item);
        LibraryPriceCalculation.CreatePriceHeader(
            PriceListHeader, PriceListHeader."Price Type"::Sale, "Price Source Type"::Customer, Customer."No.");
        LibraryPriceCalculation.CreateSalesPriceLine(
            PriceListLine, PriceListHeader.Code, "Price Source Type"::Customer, Customer."No.",
            "Price Asset Type"::Item, Item."No.");
        // [WHEN] a sales line is created for that customer and item
        LibrarySales.CreateSalesDocumentWithItem(
            SalesHeader, SalesLine, SalesHeader."Document Type"::Order, Customer."No.", Item."No.", 1, '', 0D);
        // [THEN] the sales line picks up the customer's price list line
        Assert.AreEqual(PriceListLine."Unit Price", SalesLine."Unit Price", 'Unit price must match customer price list');
    end;
}
