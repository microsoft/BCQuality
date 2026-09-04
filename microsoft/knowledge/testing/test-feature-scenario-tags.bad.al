codeunit 50102 "Item Price Testing"
{
    Subtype = Test;

    var
        ItemPriceMgt: Codeunit "Item Price Mgt.";
        Assert: Codeunit "Library Assert";

    [Test]
    procedure Test1()
    var
        Customer: Record Customer;
        Item: Record Item;
        Price, Disc: Decimal;
    begin
        // setup mixed with assertions, no clear layers
        Customer.Insert(false);
        ItemPriceMgt.GetSalesPrice(Customer."No.", Item."No.", '', Price, Disc);
        Assert.AreEqual(100, Price, '');
    end;
}
