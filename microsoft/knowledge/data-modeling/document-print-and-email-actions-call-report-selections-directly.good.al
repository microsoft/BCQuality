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
                    ReportSelections: Record "Report Selections";
                begin
                    // Calls Report Selections directly - the button's outcome
                    // depends only on this customer's registered report/layout,
                    // not on any Document Sending Profile setting.
                    ReportSelections.SendEmailToCust(
                        "Report Selection Usage"::"S.Invoice".AsInteger(), Rec, Rec."No.",
                        Rec.Name, true, Rec."No.");
                end;
            }
            action(PrintDocument)
            {
                ApplicationArea = All;
                Caption = 'Print';
                Image = Print;

                trigger OnAction()
                var
                    ReportSelections: Record "Report Selections";
                begin
                    ReportSelections.PrintWithDialogForCust(
                        "Report Selection Usage"::"S.Invoice", Rec, true, Rec.FieldNo("No."));
                end;
            }
        }
    }
}
