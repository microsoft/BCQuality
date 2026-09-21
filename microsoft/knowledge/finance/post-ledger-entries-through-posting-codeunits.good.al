// Demonstration only; independently authored, not copied from BaseApp.
codeunit 50100 "Post Transfer Journal"
{
    procedure PostTransferBatch(TemplateName: Code[10]; BatchName: Code[10])
    var
        JournalLine: Record "Gen. Journal Line";
        PostBatch: Codeunit "Gen. Jnl.-Post Batch";
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
        PostBatch.Run(JournalLine);
    end;

    var
        SingleTransferErr: Label 'Use a journal batch containing exactly one self-balancing G/L transfer.';
}
