// [FEATURE] Item Price — price cascade (Customer -> Price Group -> All Customers)
codeunit 50103 "Item Price Testing"
{
    Subtype = Test;

    var
        LibrarySales: Codeunit "Library - Sales";
        ItemPriceMgt: Codeunit "Item Price Mgt.";
        Assert: Codeunit "Library Assert";

    // [SCENARIO] Customer with a specific price list line gets that unit price
    [Test]
    procedure GetPrice_CustomerPrice_ReturnsUnitPrice()
    var
        Customer: Record Customer;
        Item: Record Item;
        UnitPrice, LineDiscPct: Decimal;
    begin
        // [GIVEN] a customer with a price list line at 100 LCY
        LibrarySales.CreateCustomerWithPrice(Customer, Item, '', 100);
        // [WHEN]
        ItemPriceMgt.GetSalesPrice(Customer."No.", Item."No.", '', UnitPrice, LineDiscPct);
        // [THEN]
        Assert.AreEqual(100, UnitPrice, 'Unit price must match customer price list');
    end;
}
