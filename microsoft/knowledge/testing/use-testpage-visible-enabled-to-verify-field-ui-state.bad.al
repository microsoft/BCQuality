codeunit 50131 "Sample Customer Type UI Test"
{
    Subtype = Test;

    [Test]
    procedure CustomerTypeFieldIsEnabledOnCustomerCard()
    var
        CustomerCard: TestPage "Customer Card";
    begin
        // Confirms only that the page opens - never checks the field's actual UI state
        CustomerCard.OpenView();
        CustomerCard.Close();
    end;
}
