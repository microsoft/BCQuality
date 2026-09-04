codeunit 50104 "Item Price Testing"
{
    Subtype = Test;

    [Test]
    procedure GetPrice_LogicTest()
    var
        Customer: Record Customer;
        Item: Record Item;
        UnitPrice, LineDiscPct: Decimal;
    begin
        // logic test — fine on its own, but not paired with a UI test below
        ItemPriceMgt.GetSalesPrice(Customer."No.", Item."No.", '', UnitPrice, LineDiscPct);
    end;

    [Test]
    procedure Page_ShowsPrice_UT()
    var
        ItemPricePage: TestPage "Item Price";
    begin
        // UI test mixed into a logic-test codeunit, and the codeunit lacks the _UT suffix
        ItemPricePage.OpenNew();
    end;
}
