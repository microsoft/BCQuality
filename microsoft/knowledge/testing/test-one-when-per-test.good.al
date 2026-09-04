[Test]
procedure GetPrice_CustomerPrice_ReturnsCorrectUnitPrice()
var
    Customer: Record Customer;
    Item: Record Item;
    UnitPrice, LineDiscPct: Decimal;
begin
    // [GIVEN] a customer with a price list line at 100
    LibrarySales.CreateCustomerWithPrice(Customer, Item, '', 100);
    // [WHEN]
    ItemPriceMgt.GetSalesPrice(Customer."No.", Item."No.", '', UnitPrice, LineDiscPct);
    // [THEN]
    Assert.AreEqual(100, UnitPrice, 'Unit price must match price list');
end;

[Test]
procedure GetPriceTiers_CustomerTier_ReturnsOneTierLine()
var
    Customer: Record Customer;
    Item: Record Item;
    TempBuffer: Record "Item Price Tier Buffer" temporary;
begin
    // [GIVEN] a customer with a tier price at min qty 10
    LibrarySales.CreateCustomerWithTierPrice(Customer, Item, '', 10, 90);
    // [WHEN]
    ItemPriceMgt.GetSalesPriceTiers(Customer."No.", Item."No.", '', TempBuffer);
    // [THEN]
    Assert.AreEqual(1, TempBuffer.Count(), 'Exactly one tier line expected');
end;
