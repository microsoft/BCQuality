pageextension 50600 "Top Invoice Headline" extends "Headline RC Order Processor"
{
    layout
    {
        addlast(Content)
        {
            group(TopInvoice)
            {
                ShowCaption = false;
                Visible = TopInvoiceVisible;

                field(TopInvoiceText; TopInvoiceText)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Top invoice headline';
                    Editable = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        TopAmount: Decimal;
    begin
        CustLedgerEntry.SetCurrentKey("Document Type", "Posting Date");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Posting Date", CalcDate('<-30D>', WorkDate()), WorkDate());
        CustLedgerEntry.SetLoadFields("Sales (LCY)");
        if CustLedgerEntry.FindSet() then
            repeat
                if CustLedgerEntry."Sales (LCY)" > TopAmount then
                    TopAmount := CustLedgerEntry."Sales (LCY)";
            until CustLedgerEntry.Next() = 0;

        TopInvoiceVisible := TopAmount > 0;
        TopInvoiceText := StrSubstNo(TopInvoiceTxt, TopAmount);
    end;

    var
        TopInvoiceVisible: Boolean;
        TopInvoiceText: Text[250];
        TopInvoiceTxt: Label '<qualifier>Last 30 days</qualifier><payload>Your largest invoice was <emphasize>%1</emphasize></payload>', Comment = '%1 = amount';
}
