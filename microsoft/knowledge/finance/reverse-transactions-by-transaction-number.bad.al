// Demonstration only; independently authored, not copied from BaseApp.
codeunit 50106 "Reverse Selected Posting"
{
    procedure RequestReversal(SelectedEntryNo: Integer)
    var
        GLEntry: Record "G/L Entry";
        ReversalEntry: Record "Reversal Entry";
    begin
        if not GuiAllowed() then
            Error(InteractiveSessionErr);
        GLEntry.Get(SelectedEntryNo);
        GLEntry.TestField("Transaction No.");
        ReversalEntry.ReverseTransaction(GLEntry."Entry No.");
    end;

    var
        InteractiveSessionErr: Label 'Request the reversal from an interactive session.';
}
