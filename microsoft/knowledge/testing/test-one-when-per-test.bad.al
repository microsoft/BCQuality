[Test]
procedure GetPrice_ThenGetDiscount_ReturnsCorrectValues()
var
    TempBuffer: Record "Item Price Tier Buffer" temporary;
    UnitPrice, LineDiscPct: Decimal;
begin
    // [GIVEN] ...
    // [WHEN] first action
    ItemPriceMgt.GetSalesPrice(CustomerNo, ItemNo, '', UnitPrice, LineDiscPct);
    // [WHEN] second action — this is a second test in disguise
    ItemPriceMgt.GetSalesPriceTiers(CustomerNo, ItemNo, '', TempBuffer);
    // [THEN] asserting two unrelated things
    Assert.AreEqual(100, UnitPrice, '');
    Assert.IsFalse(TempBuffer.IsEmpty(), '');
end;
