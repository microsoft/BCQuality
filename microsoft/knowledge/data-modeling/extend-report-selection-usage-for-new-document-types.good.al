enumextension 50100 "Sample Report Selection Usage Ext" extends "Report Selection Usage"
{
    value(50100; "Sample.SettlementDoc")
    {
        Caption = 'Sample Settlement Document';
    }
}

// This document is only ever issued to a customer, so only the customer-side
// page-facing enum is extended - not the vendor-side one too. This mirrors
// BCApps' ReportSelectionHandlerCZZ, which extends "Custom Report Selection
// Sales" for its customer-only usages and "Report Selection Usage Vendor"
// for its vendor-only usages, never both for the same one-sided value.
enumextension 50101 "Sample Cust. Rep. Sel. Sales Ext" extends "Custom Report Selection Sales"
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
    // Customer-only document: all three subscribers below are on
    // "Customer Report Selections" only. There are no matching subscribers
    // on "Vendor Report Selections" - subscribing there too would be the
    // overbroad mistake this sample avoids (see the .bad.al companion and
    // the article's Anti Pattern #2).

    // 1) Map: lets an existing row display in the Usage column instead of
    // showing blank.
    [EventSubscriber(ObjectType::Page, Page::"Customer Report Selections", 'OnAfterOnMapTableUsageValueToPageValue', '', false, false)]
    local procedure AddSampleUsageOnAfterOnMapTableUsageValueToPageValue(var Usage2: Enum "Custom Report Selection Sales"; CustomReportSelection: Record "Custom Report Selection")
    begin
        if CustomReportSelection.Usage = "Report Selection Usage"::"Sample.SettlementDoc" then
            Usage2 := "Custom Report Selection Sales"::"Sample.SettlementDoc";
    end;

    // 2) Validate: lets a user pick the new value from the Usage dropdown.
    [EventSubscriber(ObjectType::Page, Page::"Customer Report Selections", 'OnValidateUsage2OnCaseElse', '', false, false)]
    local procedure AddSampleUsageOnValidateUsage2OnCaseElse(var CustomReportSelection: Record "Custom Report Selection"; ReportUsage: Option)
    begin
        if ReportUsage = "Custom Report Selection Sales"::"Sample.SettlementDoc".AsInteger() then
            CustomReportSelection.Usage := "Report Selection Usage"::"Sample.SettlementDoc";
    end;

    // 3) Filter: wires "Copy from Report Selection" - the piece most
    // guidance stops at, appending to whatever filter already exists rather
    // than replacing it.
    [EventSubscriber(ObjectType::Page, Page::"Customer Report Selections", 'OnAfterFilterCustomerUsageReportSelections', '', false, false)]
    local procedure AddSampleUsageOnAfterFilterCustomerUsageReportSelections(var ReportSelections: Record "Report Selections")
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
