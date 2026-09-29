codeunit 50133 "Sample Customer Type Edit Test"
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

        // [WHEN] the page is opened in edit mode on that record
        CustomerTypeCard.OpenEdit();
        CustomerTypeCard.GoToRecord(CustomerType);

        // [THEN] the field's actual editable state reflects the lock
        Assert.IsFalse(CustomerTypeCard.Description.Editable(), 'Description should not be editable while Locked is set.');

        CustomerTypeCard.Close();
    end;
}
