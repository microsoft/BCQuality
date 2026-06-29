codeunit 50402 "Test Table Relation Good"
{
    Subtype = Test;

    [Test]
    procedure SalesLineAcceptsExistingItem()
    var
        Customer: Record Customer;
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [GIVEN] the parents exist first: customer, then item
        LibrarySales.CreateCustomer(Customer);
        LibraryInventory.CreateItem(Item);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");

        // [WHEN] a dependent sales line references the existing item
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 1);

        // [THEN] the TableRelation on "No." resolves and the line persists
        Assert.AreEqual(Item."No.", SalesLine."No.", 'Sales line should carry the created item.');
    end;

    var
        Assert: Codeunit "Library Assert";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
}
