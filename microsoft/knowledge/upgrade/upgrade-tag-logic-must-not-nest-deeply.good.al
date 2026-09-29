local procedure UpgradeCustomerDiscountField()
begin
    if UpgradeTag.HasUpgradeTag(GetCustomerDiscountFieldTag()) then
        exit;

    Customer.SetLoadFields("Discount %", "Customer Posting Group");
    if Customer.FindSet() then
        repeat
            // A business-data safety condition inside this one migration's
            // loop is not a second migration hiding inside the first -
            // Microsoft's own upgrade-tag example nests exactly this shape
            // (a corruption guard, then a redundant-write guard) inside a
            // single tagged procedure.
            if (Customer."Discount %" = 0) and (Customer."Customer Posting Group" <> '') then begin
                Customer."Discount %" := 5;
                Customer.Modify();
            end;
        until Customer.Next() = 0;

    UpgradeTag.SetUpgradeTag(GetCustomerDiscountFieldTag());
end;

// A second, genuinely unrelated migration gets its own tag and its own
// top-level procedure - not nested inside the first one's guarded body.
local procedure UpgradeCustomerShippingAgentField()
begin
    if UpgradeTag.HasUpgradeTag(GetCustomerShippingAgentFieldTag()) then
        exit;

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
