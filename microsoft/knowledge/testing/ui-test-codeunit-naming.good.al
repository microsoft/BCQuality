codeunit 50105 "Item Price Testing"
{
    Subtype = Test;

    [Test]
    procedure GetPrice_CustomerPrice_ReturnsUnitPrice()
    var
        Customer: Record Customer;
        Item: Record Item;
        UnitPrice, LineDiscPct: Decimal;
    begin
        ItemPriceMgt.GetSalesPrice(Customer."No.", Item."No.", '', UnitPrice, LineDiscPct);
    end;
}

codeunit 50106 "Item Price Testing_UT"
{
    Subtype = Test;

    [Test]
    procedure Page_EnterCustomerAndItem_FactBoxShowsPrice()
    var
        Customer: Record Customer;
        Item: Record Item;
        ItemPricePage: TestPage "Item Price";
        Assert: Codeunit "Library Assert";
    begin
        ItemPricePage.OpenNew();
        ItemPricePage.CustomerNo.SetValue(Customer."No.");
        ItemPricePage.ItemNo.SetValue(Item."No.");
        Assert.AreEqual('100.00', ItemPricePage.PriceInfo.UnitPrice.Value(), '');
    end;
}
