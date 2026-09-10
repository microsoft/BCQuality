codeunit 50105 "Item Price Testing"
{
    Subtype = Test;

    [Test]
    procedure ApplyDiscount_ReducesUnitPrice()
    var
        Assert: Codeunit "Library Assert";
        DiscountedPrice: Decimal;
    begin
        DiscountedPrice := ApplyDiscount(100, 10);
        Assert.AreEqual(90, DiscountedPrice, 'A 10% discount on 100 must yield 90');
    end;

    local procedure ApplyDiscount(UnitPrice: Decimal; DiscountPct: Decimal): Decimal
    begin
        exit(UnitPrice - (UnitPrice * DiscountPct / 100));
    end;
}

codeunit 50106 "Item Price Testing_UT"
{
    Subtype = Test;

    [Test]
    procedure CustomerCard_SetName_UpdatesField()
    var
        Customer: Record Customer;
        CustomerCard: TestPage "Customer Card";
        Assert: Codeunit "Library Assert";
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateCustomer(Customer);
        CustomerCard.OpenEdit();
        CustomerCard.GoToRecord(Customer);
        CustomerCard.Name.SetValue('Updated Name');
        CustomerCard.Close();

        Customer.Get(Customer."No.");
        Assert.AreEqual('Updated Name', Customer.Name, 'Name must be updated through the page');
    end;
}
