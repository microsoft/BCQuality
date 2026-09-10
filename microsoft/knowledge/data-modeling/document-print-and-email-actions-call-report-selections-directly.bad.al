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
                    // part of a combined Post-and-Send action - but routing
                    // it through Document Sending Profile means the outcome
                    // now silently depends on this customer's assigned
                    // profile. If that profile's "E-Mail" option is No, the
                    // user sees nothing happen after clicking Email, with no
                    // indication that an unrelated setup field is why.
                    DocumentSendingProfile.Send(
                        "Report Selection Usage"::"S.Invoice".AsInteger(), Rec, Rec."No.", Rec."No.",
                        Rec.Name, Rec.FieldNo("No."), Rec.FieldNo("No."));
                end;
            }
        }
    }
}
