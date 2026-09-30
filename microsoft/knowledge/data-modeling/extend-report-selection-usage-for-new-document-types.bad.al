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
        // Registration ends here. No enumextension was added to
        // "Custom Report Selection Sales" (or "Report Selection Usage
        // Vendor"), and no subscriber was added to
        // OnAfterOnMapTableUsageValueToPageValue, OnValidateUsage2OnCaseElse,
        // or OnAfterFilterCustomerUsageReportSelections /
        // OnAfterFilterVendorUsageReportSelections.
        //
        // The tenant-wide default works, so the gap isn't visible in
        // testing - but on the Document Layouts page for a specific
        // customer or vendor: an existing row for this usage shows blank in
        // the Usage column (no map event), a user cannot pick this usage
        // from the Usage dropdown at all (no validate event and no
        // page-facing enum value to pick), and "Copy from Report Selection"
        // never lists it either (no filter event). No error, no visible
        // sign that anything is missing.
    end;
}
