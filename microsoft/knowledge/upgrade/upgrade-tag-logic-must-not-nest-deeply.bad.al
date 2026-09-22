local procedure UpgradeCustomerFields()
begin
    if not UpgradeTag.HasUpgradeTag(GetCustomerDiscountFieldTag()) then begin
        Customer.SetLoadFields("Discount %", "Customer Posting Group");
        if Customer.FindSet() then
            repeat
                if (Customer."Discount %" = 0) and (Customer."Customer Posting Group" <> '') then begin
                    Customer."Discount %" := 5;
                    Customer.Modify();
                end;
            until Customer.Next() = 0;
        UpgradeTag.SetUpgradeTag(GetCustomerDiscountFieldTag());

        // BUG: a second, unrelated migration's tag check nested inside the
        // first migration's guarded body. Neither tag can be checked,
        // skipped, or fixed independently of the other - a failure or a
        // deliberate skip of the discount migration silently takes the
        // shipping-agent migration down with it, and nothing in the
        // Upgrade Tags table records that the second step ran on its own.
        if not UpgradeTag.HasUpgradeTag(GetCustomerShippingAgentFieldTag()) then begin
            Customer.SetLoadFields("Shipping Agent Code");
            if Customer.FindSet() then
                repeat
                    if Customer."Shipping Agent Code" = '' then begin
                        Customer."Shipping Agent Code" := DefaultShippingAgentCode();
                        Customer.Modify();
                    end;
                until Customer.Next() = 0;
            UpgradeTag.SetUpgradeTag(GetCustomerShippingAgentFieldTag());
        end;
    end;
end;
