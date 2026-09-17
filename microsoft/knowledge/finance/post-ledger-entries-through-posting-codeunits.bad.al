// Demonstration only; independently authored, not copied from BaseApp.
codeunit 50100 "Post Transfer Journal"
{
    procedure PostTransferBatch(TemplateName: Code[10]; BatchName: Code[10])
    var
        JournalLine: Record "Gen. Journal Line";
        LastGLEntry: Record "G/L Entry";
        NextEntryNo: Integer;
    begin
        JournalLine.SetRange("Journal Template Name", TemplateName);
        JournalLine.SetRange("Journal Batch Name", BatchName);
        if JournalLine.Count() <> 1 then
            Error(SingleTransferErr);
        JournalLine.FindFirst();
        JournalLine.TestField("Account Type", JournalLine."Account Type"::"G/L Account");
        JournalLine.TestField("Bal. Account Type", JournalLine."Bal. Account Type"::"G/L Account");
        JournalLine.TestField("Account No.");
        JournalLine.TestField("Bal. Account No.");
        JournalLine.TestField("Posting Date");
        JournalLine.TestField("Document No.");
        JournalLine.TestField(Amount);
        JournalLine.TestField("Currency Code", '');
        JournalLine.TestField("Gen. Posting Type", JournalLine."Gen. Posting Type"::" ");
        JournalLine.TestField("Bal. Gen. Posting Type", JournalLine."Bal. Gen. Posting Type"::" ");

        LastGLEntry.LockTable();
        if LastGLEntry.FindLast() then
            NextEntryNo := LastGLEntry."Entry No." + 1
        else
            NextEntryNo := 1;
        InsertLedgerRow(JournalLine, NextEntryNo, JournalLine."Account No.", JournalLine.Amount);
        InsertLedgerRow(JournalLine, NextEntryNo + 1, JournalLine."Bal. Account No.", -JournalLine.Amount);
    end;

    local procedure InsertLedgerRow(JournalLine: Record "Gen. Journal Line"; EntryNo: Integer; AccountNo: Code[20]; Amount: Decimal)
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.Init();
        GLEntry."Entry No." := EntryNo;
        GLEntry."G/L Account No." := AccountNo;
        GLEntry."Posting Date" := JournalLine."Posting Date";
        GLEntry."Document Type" := JournalLine."Document Type";
        GLEntry."Document No." := JournalLine."Document No.";
        GLEntry."Source Code" := JournalLine."Source Code";
        GLEntry."Journal Batch Name" := JournalLine."Journal Batch Name";
        GLEntry."Dimension Set ID" := JournalLine."Dimension Set ID";
        GLEntry."Global Dimension 1 Code" := JournalLine."Shortcut Dimension 1 Code";
        GLEntry."Global Dimension 2 Code" := JournalLine."Shortcut Dimension 2 Code";
        GLEntry.Amount := Amount;
        if Amount > 0 then
            GLEntry."Debit Amount" := Amount
        else
            GLEntry."Credit Amount" := -Amount;
        GLEntry.Insert(true);
    end;

    var
        SingleTransferErr: Label 'Use a journal batch containing exactly one self-balancing G/L transfer.';
}
