enumextension 50100 "Sample Report Selection Usage Ext" extends "Report Selection Usage"
{
    value(50100; "Sample.SettlementDoc")
    {
        Caption = 'Sample Settlement Document';
    }
}

report 50100 "Sample Settlement Document"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem(Customer; Customer)
        {
            column(No_Customer; "No.") { }
        }
    }
}

codeunit 50100 "Sample Report Selection Install"
{
    procedure InstallDefaultReportSelection()
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.InsertRecord(
            "Report Selection Usage"::"Sample.SettlementDoc", '1', Report::"Sample Settlement Document");
        // Registration ends here. No subscriber added to
        // OnAfterFilterCustomerUsageReportSelections / OnAfterFilterVendorUsageReportSelections
        // - the tenant-wide default works, but "Copy from Report Selection"
        // on the Document Layouts page never lists this usage value, so a
        // per-account override can only be entered by hand, if a user even
        // knows to look for it.
    end;
}
