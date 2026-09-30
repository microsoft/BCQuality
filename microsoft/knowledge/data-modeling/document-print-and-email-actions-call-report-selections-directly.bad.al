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
                    DocumentSendingProfile: Record "Document Sending Profile";
                    ReportDistributionMgt: Codeunit "Report Distribution Management";
                begin
                    // WRONG: this is a plain, on-demand "Email" button, not
                    // part of a combined Post-and-Send action - but this
                    // loads the customer's ACTUAL assigned profile (or the
                    // tenant default, if none is assigned - the same lookup
                    // Sales-Post and Send performs) and calls Send on it, so
                    // the outcome now silently depends on that profile. A
                    // profile set up for Post-and-Send printing only (say,
                    // Printer = Yes, "E-Mail" = No) turns this button into a
                    // silent no-op, with no indication an unrelated setup
                    // field is why.
                    SalesInvoiceHeader := Rec;
                    CurrPage.SetSelectionFilter(SalesInvoiceHeader);
                    DocumentSendingProfile.GetDefaultForCustomer(Rec."Bill-to Customer No.", DocumentSendingProfile);
                    DocumentSendingProfile.Send(
                        "Report Selection Usage"::"S.Invoice".AsInteger(), SalesInvoiceHeader, Rec."No.",
                        Rec."Bill-to Customer No.", ReportDistributionMgt.GetFullDocumentTypeText(Rec),
                        SalesInvoiceHeader.FieldNo("Bill-to Customer No."), SalesInvoiceHeader.FieldNo("No."));
                end;
            }
        }
    }
}
