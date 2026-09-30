table 50569 "Contoso Activity Log"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer) { AutoIncrement = true; }
        field(2; "Activity"; Text[250]) { }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}

page 50570 "Contoso Activity Log"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Contoso Activity Log";
    Editable = false;
    // Registration only makes the table selectable on the Retention Policies
    // page. No Retention Policy Setup exists and nothing is deleted, yet the
    // page tells the administrator that cleanup is running.
    AboutTitle = 'About the activity log';
    AboutText = 'Entries older than six months are deleted automatically, so the log never needs manual cleanup.';

    layout
    {
        area(Content)
        {
            repeater(Entries)
            {
                field("Entry No."; Rec."Entry No.") { ToolTip = 'Specifies the entry number.'; }
                field(Activity; Rec.Activity) { ToolTip = 'Specifies the logged activity.'; }
            }
        }
    }
}

codeunit 50565 "Contoso Reten. Pol. Register"
{
    Access = Internal;

    procedure AddAllowedTables()
    var
        ContosoActivityLog: Record "Contoso Activity Log";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
    begin
        if not RetenPolAllowedTables.IsAllowedTable(Database::"Contoso Activity Log") then
            RetenPolAllowedTables.AddAllowedTable(
                Database::"Contoso Activity Log", ContosoActivityLog.FieldNo(SystemCreatedAt));
    end;
}

codeunit 50571 "Contoso Reten. Pol. Install"
{
    Subtype = Install;
    Access = Internal;

    trigger OnInstallAppPerCompany()
    var
        ContosoRetenPolRegister: Codeunit "Contoso Reten. Pol. Register";
    begin
        ContosoRetenPolRegister.AddAllowedTables();
    end;
}

codeunit 50572 "Contoso Reten. Pol. Upgrade"
{
    Subtype = Upgrade;
    Access = Internal;

    trigger OnUpgradePerCompany()
    var
        ContosoRetenPolRegister: Codeunit "Contoso Reten. Pol. Register";
    begin
        ContosoRetenPolRegister.AddAllowedTables();
    end;
}
