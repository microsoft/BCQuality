// Demonstration only; independently authored, not copied from BaseApp.
codeunit 50104 "Customer Settlement Actions"
{
    procedure RequestApplication(CustomerEntryNo: Integer)
    var
        CustomerEntry: Record "Cust. Ledger Entry";
    begin
        RequireInteractiveSession();
        CustomerEntry.Get(CustomerEntryNo);
        CustomerEntry.TestField(Open, true);
        CustomerEntry.Open := false;
        CustomerEntry.Modify(true);
    end;

    procedure RequestUnapplication(CustomerEntryNo: Integer)
    var
        DetailedCustomerEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        RequireInteractiveSession();
        DetailedCustomerEntry.SetRange("Cust. Ledger Entry No.", CustomerEntryNo);
        DetailedCustomerEntry.SetRange("Entry Type", DetailedCustomerEntry."Entry Type"::Application);
        DetailedCustomerEntry.ModifyAll(Unapplied, true);
    end;

    local procedure RequireInteractiveSession()
    begin
        if not GuiAllowed() then
            Error(InteractiveSessionErr);
    end;

    var
        InteractiveSessionErr: Label 'Request settlement from an interactive session.';
}
