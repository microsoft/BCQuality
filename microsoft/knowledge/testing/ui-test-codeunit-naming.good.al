// [FEATURE] Item pricing
codeunit 50105 "Item Price Testing"
{
    Subtype = Test;

    [Test]
    procedure ApplyDiscount_ReducesUnitPrice()
    var
        Assert: Codeunit "Library Assert";
        DiscountedPrice: Decimal;
    begin
        // [SCENARIO] A ten percent discount lowers a unit price of 100
        // [WHEN] a 10 percent discount is applied to a unit price of 100
        DiscountedPrice := ApplyDiscount(100, 10);
        // [THEN] the discounted price is 90
        Assert.AreEqual(90, DiscountedPrice, 'A 10% discount on 100 must yield 90');
    end;

    local procedure ApplyDiscount(UnitPrice: Decimal; DiscountPct: Decimal): Decimal
    begin
        exit(UnitPrice - (UnitPrice * DiscountPct / 100));
    end;
}

// [FEATURE] Customer card
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
        // [SCENARIO] A customer name entered on the customer card is saved to the customer
        // [GIVEN] a customer
        LibrarySales.CreateCustomer(Customer);
        // [WHEN] the name is changed on the customer card
        CustomerCard.OpenEdit();
        CustomerCard.GoToRecord(Customer);
        CustomerCard.Name.SetValue('Updated Name');
        CustomerCard.Close();

        // [THEN] the customer holds the new name
        Customer.Get(Customer."No.");
        Assert.AreEqual('Updated Name', Customer.Name, 'Name must be updated through the page');
    end;
}
