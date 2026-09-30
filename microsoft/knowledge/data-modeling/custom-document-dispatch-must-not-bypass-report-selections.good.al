codeunit 50102 "Sample Posted Invoice Send"
{
    procedure SendPostedInvoice(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        ReportSelections: Record "Report Selections";
        ReportDistributionMgt: Codeunit "Report Distribution Management";
    begin
        // Custom validation specific to this dispatch stays here...
        CheckReadyToSend(SalesInvoiceHeader);

        // ...but dispatch goes through the registered usage. "S.Invoice"
        // resolves to a report built on "Sales Invoice Header" (by default
        // report 1306 "Standard Sales - Invoice"), so the record passed in
        // matches what the selected report expects, and per-account
        // report/layout overrides and email attachment/body configuration
        // on Report Selections all apply automatically.
        SalesInvoiceHeader.SetRecFilter();
        ReportSelections.SendEmailToCust(
            "Report Selection Usage"::"S.Invoice".AsInteger(), SalesInvoiceHeader, SalesInvoiceHeader."No.",
            ReportDistributionMgt.GetFullDocumentTypeText(SalesInvoiceHeader), true,
            SalesInvoiceHeader."Bill-to Customer No.");
    end;

    local procedure CheckReadyToSend(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        Customer: Record Customer;
    begin
        Customer.Get(SalesInvoiceHeader."Bill-to Customer No.");
        Customer.TestField("E-Mail");
    end;
}
