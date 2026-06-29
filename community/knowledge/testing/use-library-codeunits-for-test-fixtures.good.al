codeunit 50410 "Test Library Fixtures Good"
{
    Subtype = Test;

    [Test]
    procedure OrderUsesLibraryCreatedFixtures()
    var
        Customer: Record Customer;
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // Library codeunits create valid parents: number series, mandatory
        // fields and table relations are all handled for you.
        LibrarySales.CreateCustomer(Customer);
        LibraryInventory.CreateItem(Item);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(10));

        Assert.AreEqual(Customer."No.", SalesHeader."Sell-to Customer No.", 'Header should use the created customer.');
    end;

    var
        Assert: Codeunit "Library Assert";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
}
