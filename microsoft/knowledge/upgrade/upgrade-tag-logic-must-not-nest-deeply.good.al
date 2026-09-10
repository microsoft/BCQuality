local procedure UpgradeCustomerDiscountField()
begin
    if UpgradeTag.HasUpgradeTag(GetCustomerDiscountFieldTag()) then
        exit;

    Customer.SetLoadFields("Discount %");
    if Customer.FindSet() then
        repeat
            Customer."Discount %" := 5;
            Customer.Modify();
        until Customer.Next() = 0;

    UpgradeTag.SetUpgradeTag(GetCustomerDiscountFieldTag());
end;
