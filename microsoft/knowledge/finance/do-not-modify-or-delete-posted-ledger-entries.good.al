// Demonstration only; independently authored, not copied from BaseApp.
codeunit 50101 "Correct Posted Transaction"
{
    procedure RequestTransactionReversal(EntryNo: Integer)
    var
        GLEntry: Record "G/L Entry";
        ReversalEntry: Record "Reversal Entry";
    begin
        if not GuiAllowed() then
            Error(InteractiveSessionErr);
        GLEntry.Get(EntryNo);
        GLEntry.TestField("Transaction No.");
        ReversalEntry.ReverseTransaction(GLEntry."Transaction No.");
    end;

    procedure UpdateDescription(EntryNo: Integer; NewDescription: Text[100])
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.Get(EntryNo);
        GLEntry.Description := NewDescription;
        Codeunit.Run(Codeunit::"G/L Entry-Edit", GLEntry);
    end;

    procedure ClearSimulation(var TempGLEntry: Record "G/L Entry" temporary)
    begin
        TempGLEntry.DeleteAll();
    end;

    var
        InteractiveSessionErr: Label 'Request the reversal from an interactive session.';
}
