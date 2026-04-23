tableextension 50810 "Upgrade Sample InitValue Good" extends Customer
{
    fields
    {
        field(50100; "Is Active"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Is active';
            InitValue = true;
        }
    }
}

codeunit 50811 "Upgrade Sample InitValue Good Upg"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeExistingCustomersIsActive();
    end;

    local procedure UpgradeExistingCustomersIsActive()
    var
        Customer: Record Customer;
        CustomerDataTransfer: DataTransfer;
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeCustomerIsActiveTag()) then
            exit;

        CustomerDataTransfer.SetTables(Database::Customer, Database::Customer);
        CustomerDataTransfer.AddConstantValue(true, Customer.FieldNo("Is Active"));
        CustomerDataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeCustomerIsActiveTag());
    end;

    local procedure UpgradeCustomerIsActiveTag(): Code[250]
    begin
        exit('MS-000006-CustomerIsActive-20260501');
    end;
}
