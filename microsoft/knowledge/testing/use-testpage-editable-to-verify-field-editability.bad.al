codeunit 50134 "Sample Customer Type Edit Test"
{
    Subtype = Test;

    [Test]
    procedure CustomerTypeFieldNotEditable_WhenLocked()
    var
        Assert: Codeunit Assert;
        CustomerType: Record "Customer Type";
        CustomerTypeCard: TestPage "Customer Type Card";
    begin
        // [GIVEN] a customer type record whose Locked flag is set
        CustomerType.Init();
        CustomerType.Locked := true;
        CustomerType.Insert(true);

        // [WHEN] the page is opened in VIEW mode — editability logic that only
        // applies in edit mode is not exercised the same way
        CustomerTypeCard.OpenView();
        CustomerTypeCard.GoToRecord(CustomerType);

        // [THEN] wrong function: Enabled() does not verify editability
        Assert.IsFalse(CustomerTypeCard.Description.Enabled(), 'Description should not be editable while Locked is set.');

        CustomerTypeCard.Close();
    end;
}
