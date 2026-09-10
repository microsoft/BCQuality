report 50102 "Sample Settlement Doc Bad"
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

codeunit 50102 "Sample Settlement Document Send"
{
    procedure SendSettlementDocument(var Customer: Record Customer)
    begin
        Customer.TestField("E-Mail");

        // WRONG: hardcoded report, no Report Selections row backing it.
        // Works for the default case, but there is nowhere for an admin to
        // change the report or layout for one specific customer - this
        // document never shows up on "Document Layouts" at all, and the
        // only way to change it is a code change and a new release.
        Report.RunModal(Report::"Sample Settlement Doc Bad", false, false, Customer);
    end;
}
