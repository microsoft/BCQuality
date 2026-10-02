codeunit 50261 "Upgrade All Companies"
{
    Subtype = Upgrade;

    trigger OnUpgradePerDatabase()
    var
        Company: Record Company;
        SalesOrderExt: Record "Sales Order Ext";
    begin
        // Reaches into every company from one session. Each company also has its own
        // upgrade session, triggers and subscribers run in the calling context, and a
        // data error in any company aborts the whole upgrade.
        if Company.FindSet() then
            repeat
                SalesOrderExt.ChangeCompany(Company.Name);
                SalesOrderExt.SetRange("Shipping Agent Code", '');
                if SalesOrderExt.FindSet(true) then
                    repeat
                        SalesOrderExt.Validate("Shipping Agent Code", SalesOrderExt."Legacy Carrier Code");
                        SalesOrderExt.Modify(true);
                    until SalesOrderExt.Next() = 0;
            until Company.Next() = 0;
    end;
}
