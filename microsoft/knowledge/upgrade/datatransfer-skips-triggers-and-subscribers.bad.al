codeunit 50221 "Upgrade Existing Field"
{
    Subtype = Upgrade;

    local procedure UpdateCustomerCreditLimit()
    var
        Customer: Record Customer;
        DT: DataTransfer;
    begin
        // DataTransfer skips the field's OnValidate logic and validation events,
        // plus the table OnModify trigger and row-based modification events.
        DT.SetTables(Database::Customer, Database::Customer);
        DT.AddConstantValue(50000, Customer.FieldNo("Credit Limit (LCY)"));
        DT.CopyFields();
    end;
}
