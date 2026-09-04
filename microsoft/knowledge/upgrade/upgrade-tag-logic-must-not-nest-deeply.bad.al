local procedure UpgradeCustomerDiscountField()
begin
    if not UpgradeTag.HasUpgradeTag(GetCustomerDiscountFieldTag()) then begin
        if Customer.FindSet() then begin
            repeat
                if Customer."Discount %" = 0 then begin
                    if Customer."Customer Posting Group" <> '' then
                        Customer."Discount %" := 5;
                end;
            until Customer.Next() = 0;
        end;
        UpgradeTag.SetUpgradeTag(GetCustomerDiscountFieldTag());
    end;
end;
