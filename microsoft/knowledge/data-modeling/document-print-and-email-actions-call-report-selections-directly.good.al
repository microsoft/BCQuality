page 50101 "Sample Posted Invoice Card"
{
    PageType = Card;
    SourceTable = "Sales Invoice Header";
    ApplicationArea = All;
    Editable = false;

    actions
    {
        area(Processing)
        {
            action(EmailDocument)
            {
                ApplicationArea = All;
                Caption = 'Email';
                Image = Email;

                trigger OnAction()
                var
                    SalesInvoiceHeader: Record "Sales Invoice Header";
                    ReportSelections: Record "Report Selections";
                    ReportDistributionMgt: Codeunit "Report Distribution Management";
                begin
                    // Calls Report Selections directly - the button's outcome
                    // depends only on this customer's registered report/layout,
                    // not on any Document Sending Profile setting. Calling
                    // DocumentSendingProfile.TrySendToEMail(...) instead would
                    // also be correct, because it never reads the customer's
                    // assigned profile: it only uses a local record that it
                    // never retrieves with Get, and sets its "E-Mail" option
                    // itself. The
                    // anti-pattern is Get/GetDefaultForCustomer followed by
                    // Send, which makes the outcome depend on that profile.
                    // "S.Invoice" resolves to a report on "Sales Invoice
                    // Header", which is the record passed here.
                    SalesInvoiceHeader := Rec;
                    CurrPage.SetSelectionFilter(SalesInvoiceHeader);
                    ReportSelections.SendEmailToCust(
                        "Report Selection Usage"::"S.Invoice".AsInteger(), SalesInvoiceHeader, Rec."No.",
                        ReportDistributionMgt.GetFullDocumentTypeText(Rec), true, Rec."Bill-to Customer No.");
                end;
            }
            action(PrintDocument)
            {
                ApplicationArea = All;
                Caption = 'Print';
                Image = Print;

                trigger OnAction()
                var
                    SalesInvoiceHeader: Record "Sales Invoice Header";
                    ReportSelections: Record "Report Selections";
                begin
                    SalesInvoiceHeader := Rec;
                    CurrPage.SetSelectionFilter(SalesInvoiceHeader);
                    ReportSelections.PrintWithDialogForCust(
                        "Report Selection Usage"::"S.Invoice", SalesInvoiceHeader, true,
                        SalesInvoiceHeader.FieldNo("Bill-to Customer No."));
                end;
            }
        }
    }
}
