report 50547 "Sample Statement Good"
{
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    Caption = 'Sample Statement Good';

    dataset
    {
        dataitem(CustLedgerEntry; "Cust. Ledger Entry")
        {
            column(CustomerNo; "Customer No.") { }
            column(Amount; Amount) { }
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    field(StatementDateField; StatementDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Statement Date';
                        ToolTip = 'Specifies the date the statement is printed for.';
                        ShowMandatory = true;
                    }
                }
            }
        }

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            // Only when the user confirmed the run. Erroring on Cancel or Esc
            // would trap the user in a page that refuses to close. The error
            // itself keeps the page open, so the date can be fixed in place.
            if CloseAction = Action::OK then
                CheckStatementDate();
        end;
    }

    var
        StatementDate: Date;
        StatementDateMissingErr: Label 'Enter a statement date.';

    trigger OnPreReport()
    begin
        // The same check for runs that have no request page: job queue entries,
        // Report.Run with the request window suppressed, scheduled and
        // web-service invocations.
        CheckStatementDate();
    end;

    local procedure CheckStatementDate()
    begin
        if StatementDate = 0D then
            Error(StatementDateMissingErr);
    end;
}
