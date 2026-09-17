report 50545 "Sample Statement Late Check"
{
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    Caption = 'Sample Statement Late Check';

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
        // No OnQueryClosePage: nothing inspects the input while the page is open.
    }

    var
        StatementDate: Date;
        StatementDateMissingErr: Label 'Enter a statement date.';

    trigger OnPreReport()
    begin
        // The request page is already closed. The user cannot correct the date
        // here — the run is aborted and every entry on the page is lost.
        if StatementDate = 0D then
            Error(StatementDateMissingErr);
    end;
}

report 50546 "Sample Statement Close Trap"
{
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    Caption = 'Sample Statement Close Trap';

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
            // No close-action guard. Cancel and Esc raise the error too, and an
            // error prevents the page from closing — the user cannot get out.
            if StatementDate = 0D then
                Error(StatementDateMissingErr);
        end;
    }

    var
        StatementDate: Date;
        StatementDateMissingErr: Label 'Enter a statement date.';
}
