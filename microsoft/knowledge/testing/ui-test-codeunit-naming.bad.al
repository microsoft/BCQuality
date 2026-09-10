codeunit 50104 "Item Price Testing"
{
    Subtype = Test;

    [Test]
    procedure ApplyDiscount_LogicTest()
    var
        Assert: Codeunit "Library Assert";
    begin
        // logic test — fine on its own, but not paired with a UI test below
        Assert.AreEqual(90, ApplyDiscount(100, 10), 'A 10% discount on 100 must yield 90');
    end;

    local procedure ApplyDiscount(UnitPrice: Decimal; DiscountPct: Decimal): Decimal
    begin
        exit(UnitPrice - (UnitPrice * DiscountPct / 100));
    end;

    [Test]
    procedure CustomerCard_Opens_UT()
    var
        CustomerCard: TestPage "Customer Card";
    begin
        // UI test mixed into a logic-test codeunit, and the codeunit lacks the _UT suffix
        CustomerCard.OpenNew();
    end;
}
