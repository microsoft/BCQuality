codeunit 50102 "Item Price Testing"
{
    Subtype = Test;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPriceCalculation: Codeunit "Library - Price Calculation";
        Assert: Codeunit "Library Assert";

    [Test]
    procedure Test1()
    var
        Customer: Record Customer;
        Item: Record Item;
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // setup mixed with assertions, no clear layers, no FEATURE/SCENARIO/GIVEN/WHEN/THEN tags
        LibrarySales.CreateCustomer(Customer);
        LibraryInventory.CreateItem(Item);
        LibraryPriceCalculation.CreatePriceHeader(
            PriceListHeader, PriceListHeader."Price Type"::Sale, "Price Source Type"::Customer, Customer."No.");
        LibraryPriceCalculation.CreateSalesPriceLine(
            PriceListLine, PriceListHeader.Code, "Price Source Type"::Customer, Customer."No.",
            "Price Asset Type"::Item, Item."No.");
        LibrarySales.CreateSalesDocumentWithItem(
            SalesHeader, SalesLine, SalesHeader."Document Type"::Order, Customer."No.", Item."No.", 1, '', 0D);
        Assert.AreEqual(PriceListLine."Unit Price", SalesLine."Unit Price", '');
    end;
}
