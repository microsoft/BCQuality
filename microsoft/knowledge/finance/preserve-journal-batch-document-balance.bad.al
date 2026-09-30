// Demonstration only; independently authored, not copied from BaseApp.
codeunit 50107 "Post Journal Allocation"
{
    procedure PostAllocation(TemplateName: Code[10]; BatchName: Code[10]; DebitAccount: Code[20]; CreditAccount: Code[20]; PostingDate: Date)
    var
        JournalTemplate: Record "Gen. Journal Template";
        JournalBatch: Record "Gen. Journal Batch";
        JournalLine: Record "Gen. Journal Line";
        LineToPost: Record "Gen. Journal Line";
        PostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        JournalTemplate.Get(TemplateName);
        JournalTemplate.TestField(Recurring, false);
        JournalTemplate.TestField("Force Doc. Balance", true);
        JournalTemplate.TestField("Source Code");
        JournalBatch.Get(TemplateName, BatchName);
        JournalBatch.TestField("No. Series", '');
        JournalBatch.TestField("Posting No. Series", '');
        JournalLine.SetRange("Journal Template Name", TemplateName);
        JournalLine.SetRange("Journal Batch Name", BatchName);
        if not JournalLine.IsEmpty() then
            Error(EmptyBatchErr);

        AddAllocationLine(JournalTemplate, BatchName, 10000, DebitAccount, PostingDate, 'ALLOC-A', 90);
        AddAllocationLine(JournalTemplate, BatchName, 20000, CreditAccount, PostingDate, 'ALLOC-B', -90);
        JournalLine.FindSet();
        repeat
            LineToPost := JournalLine;
            PostLine.RunWithCheck(LineToPost);
        until JournalLine.Next() = 0;
    end;

    local procedure AddAllocationLine(JournalTemplate: Record "Gen. Journal Template"; BatchName: Code[10]; LineNo: Integer; AccountNo: Code[20]; PostingDate: Date; DocumentNo: Code[20]; LineAmount: Decimal)
    var
        JournalLine: Record "Gen. Journal Line";
    begin
        JournalLine.Init();
        JournalLine."Journal Template Name" := JournalTemplate.Name;
        JournalLine."Journal Batch Name" := BatchName;
        JournalLine."Line No." := LineNo;
        JournalLine."Source Code" := JournalTemplate."Source Code";
        JournalLine.Validate("Posting Date", PostingDate);
        JournalLine.Validate("Document No.", DocumentNo);
        JournalLine.Validate("Account Type", JournalLine."Account Type"::"G/L Account");
        JournalLine.Validate("Account No.", AccountNo);
        JournalLine.Validate("Gen. Posting Type", JournalLine."Gen. Posting Type"::" ");
        JournalLine.Validate(Amount, LineAmount);
        JournalLine.Insert(true);
    end;

    var
        EmptyBatchErr: Label 'Use an empty journal batch for this allocation.';
}
