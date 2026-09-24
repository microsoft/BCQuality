page 50101 "Sample Settlement Document Card"
{
    PageType = Card;
    SourceTable = Customer;
    ApplicationArea = All;

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
                    DocumentSendingProfile: Record "Document Sending Profile";
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
                    DocumentSendingProfile.GetDefaultForCustomer(Rec."No.", DocumentSendingProfile);
                    DocumentSendingProfile.Send(
                        "Report Selection Usage"::"S.Invoice".AsInteger(), Rec, Rec."No.", Rec."No.",
                        Rec.Name, Rec.FieldNo("No."), Rec.FieldNo("No."));
                end;
            }
        }
    }
}
