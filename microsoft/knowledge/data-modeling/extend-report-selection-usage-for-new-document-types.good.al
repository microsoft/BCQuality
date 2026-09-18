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
    end;
}

codeunit 50101 "Sample Report Selection Subscribers"
{
    // Appends to whatever the standard filter already contains, following
    // the real BCApps pattern in ReportSelectionHandlerCZC.Codeunit.al.
    [EventSubscriber(ObjectType::Page, Page::"Customer Report Selections", 'OnAfterFilterCustomerUsageReportSelections', '', false, false)]
    local procedure AddSampleUsageOnAfterFilterCustomerUsageReportSelections(var ReportSelections: Record "Report Selections")
    begin
        ReportSelections.SetFilter(Usage, GetUsageFilter(ReportSelections));
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor Report Selections", 'OnAfterFilterVendorUsageReportSelections', '', false, false)]
    local procedure AddSampleUsageOnAfterFilterVendorUsageReportSelections(var ReportSelections: Record "Report Selections")
    begin
        ReportSelections.SetFilter(Usage, GetUsageFilter(ReportSelections));
    end;

    local procedure GetUsageFilter(var ReportSelections: Record "Report Selections") UsageFilter: Text
    begin
        UsageFilter := Format("Report Selection Usage"::"Sample.SettlementDoc");
        if ReportSelections.GetFilter(Usage) <> '' then
            UsageFilter := StrSubstNo('%1|%2', ReportSelections.GetFilter(Usage), UsageFilter);
    end;
}
