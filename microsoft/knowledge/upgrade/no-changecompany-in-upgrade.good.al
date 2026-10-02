codeunit 50260 "Upgrade Current Company"
{
    Subtype = Upgrade;

    // The platform runs this trigger once per company, in that company's own session.
    trigger OnUpgradePerCompany()
    begin
        UpgradeShippingAgentCodes();
    end;

    local procedure UpgradeShippingAgentCodes()
    var
        SalesOrderExt: Record "Sales Order Ext";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(ShippingAgentUpgradeTag()) then
            exit;

        // Only the current company's rows; triggers, events, and the tag all apply here.
        SalesOrderExt.SetRange("Shipping Agent Code", '');
        if SalesOrderExt.FindSet(true) then
            repeat
                SalesOrderExt.Validate("Shipping Agent Code", SalesOrderExt."Legacy Carrier Code");
                SalesOrderExt.Modify(true);
            until SalesOrderExt.Next() = 0;

        UpgradeTag.SetUpgradeTag(ShippingAgentUpgradeTag());
    end;

    local procedure ShippingAgentUpgradeTag(): Code[250]
    begin
        exit('CONTOSO-1001-ShippingAgentCode-20260101');
    end;
}
