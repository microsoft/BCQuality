codeunit 50808 "Upgrade Sample DataTransfer Good"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        InitializeNewFlag();
    end;

    local procedure InitializeNewFlag()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CLEDataTransfer: DataTransfer;
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(InitializeNewFlagTag()) then
            exit;

        CLEDataTransfer.SetTables(Database::"Cust. Ledger Entry", Database::"Cust. Ledger Entry");
        CLEDataTransfer.AddSourceFilter(CustLedgerEntry.FieldNo(Open), '=%1', true);
        CLEDataTransfer.AddConstantValue(false, CustLedgerEntry.FieldNo("New Flag"));
        CLEDataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(InitializeNewFlagTag());
    end;

    local procedure InitializeNewFlagTag(): Code[250]
    begin
        exit('MS-000005-CLEInitializeNewFlag-20260501');
    end;
}
