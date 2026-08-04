// Demonstration only. Self-contained illustration, not derived from the
// Business Central base application source.
//
// GOOD: build a journal line and let the posting engine create the ledger
// entry. The platform assigns Entry No., writes the balancing entry, creates
// the register, and resolves dimensions and VAT.
codeunit 50100 "Post GL Adjustment"
{
    procedure PostAdjustment(AccountNo: Code[20]; BalAccountNo: Code[20]; Amount: Decimal; PostingDate: Date)
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        GenJnlLine.Init();
        GenJnlLine."Posting Date" := PostingDate;
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::" ";
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine.Validate("Account No.", AccountNo);
        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
        GenJnlLine.Validate("Bal. Account No.", BalAccountNo);
        GenJnlLine.Validate(Amount, Amount);
        GenJnlLine."Source Code" := 'ADJUST';

        GenJnlPostLine.Run(GenJnlLine);
    end;
}
