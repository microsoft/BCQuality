codeunit 50131 "Sample Customer Type UI Test"
{
    Subtype = Test;

    [Test]
    procedure CustomerTypeFieldIsEnabledOnCustomerCard()
    var
        Assert: Codeunit Assert;
        CustomerCard: TestPage "Customer Card";
    begin
        CustomerCard.OpenView();
        Assert.IsTrue(CustomerCard."Customer Type".Enabled(), 'Customer Type should be editable on the Customer Card.');
        Assert.IsTrue(CustomerCard."Customer Type".Visible(), 'Customer Type should be visible on the Customer Card.');
    end;
}
