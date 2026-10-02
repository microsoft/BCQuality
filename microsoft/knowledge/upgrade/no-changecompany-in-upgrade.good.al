table 50262 "Sales Order Ext"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20]) { }
        field(2; "Shipping Agent Code"; Code[10]) { TableRelation = "Shipping Agent"; }
        field(3; "Legacy Carrier Code"; Code[10]) { }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
    }
}

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

codeunit 50264 "Shipping Agent Feat. Data Upd." implements "Feature Data Update"
{
    // Read-only preflight: counting rows across companies to report scope is allowed.
    procedure IsDataUpdateRequired(): Boolean
    var
        Company: Record Company;
        SalesOrderExt: Record "Sales Order Ext";
    begin
        if Company.FindSet() then
            repeat
                SalesOrderExt.ChangeCompany(Company.Name);
                SalesOrderExt.SetRange("Shipping Agent Code", '');
                if not SalesOrderExt.IsEmpty() then
                    exit(true);
            until Company.Next() = 0;
        exit(false);
    end;

    procedure ReviewData()
    begin
    end;

    // Feature Management runs this once per company, in that company.
    procedure UpdateData(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        SalesOrderExt: Record "Sales Order Ext";
    begin
        SalesOrderExt.SetRange("Shipping Agent Code", '');
        if SalesOrderExt.FindSet(true) then
            repeat
                SalesOrderExt.Validate("Shipping Agent Code", SalesOrderExt."Legacy Carrier Code");
                SalesOrderExt.Modify(true);
            until SalesOrderExt.Next() = 0;
    end;

    procedure AfterUpdate(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    begin
    end;

    procedure GetTaskDescription(): Text
    begin
        exit('Copies legacy carrier codes to the shipping agent code.');
    end;
}
