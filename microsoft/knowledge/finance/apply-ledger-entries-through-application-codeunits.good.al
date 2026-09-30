// Demonstration only; independently authored, not copied from BaseApp.
codeunit 50104 "Customer Settlement Actions"
{
    procedure RequestApplication(CustomerEntryNo: Integer)
    var
        CustomerEntry: Record "Cust. Ledger Entry";
        CustomerApplication: Codeunit "CustEntry-Apply Posted Entries";
    begin
        RequireInteractiveSession();
        CustomerEntry.Get(CustomerEntryNo);
        CustomerEntry.TestField(Open, true);
        CustomerApplication.ApplyCustEntryFormEntry(CustomerEntry);
    end;

    procedure RequestUnapplication(CustomerEntryNo: Integer)
    var
        CustomerApplication: Codeunit "CustEntry-Apply Posted Entries";
    begin
        RequireInteractiveSession();
        CustomerApplication.UnApplyCustLedgEntry(CustomerEntryNo);
    end;

    local procedure RequireInteractiveSession()
    begin
        if not GuiAllowed() then
            Error(InteractiveSessionErr);
    end;

    var
        InteractiveSessionErr: Label 'Request settlement from an interactive session.';
}
