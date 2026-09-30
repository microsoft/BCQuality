codeunit 50102 "Sample Posted Invoice Send"
{
    procedure SendPostedInvoice(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        Customer: Record Customer;
    begin
        Customer.Get(SalesInvoiceHeader."Bill-to Customer No.");
        Customer.TestField("E-Mail");

        // WRONG: the report is hardcoded instead of resolved through the
        // registered "S.Invoice" usage in Report Selections. This alone is
        // the defect - no hand-built email is needed for it: a Report
        // Selections row or a per-customer "Document Layouts" override
        // that points this usage at a different report or layout is
        // silently ignored, and the only way to change what this code
        // prints is a code change and a new release.
        SalesInvoiceHeader.SetRecFilter();
        Report.RunModal(Report::"Standard Sales - Invoice", false, false, SalesInvoiceHeader);
    end;
}
