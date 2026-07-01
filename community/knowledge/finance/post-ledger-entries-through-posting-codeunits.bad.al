// Demonstration only. Self-contained illustration, not derived from the
// Business Central base application source.
//
// BAD: insert straight into the ledger table and hand-compute Entry No.
// The row is unbalanced (no balancing entry), has no register, no resolved
// dimensions, and no VAT. FindLast + "+ 1" races under concurrency and will
// collide on the primary key. Reconciliation treats the result as corrupt.
codeunit 50100 "Post GL Adjustment"
{
    procedure PostAdjustment(AccountNo: Code[20]; Amount: Decimal; PostingDate: Date)
    var
        GLEntry: Record "G/L Entry";
        LastGLEntry: Record "G/L Entry";
    begin
        if LastGLEntry.FindLast() then;

        GLEntry.Init();
        GLEntry."Entry No." := LastGLEntry."Entry No." + 1;
        GLEntry."G/L Account No." := AccountNo;
        GLEntry.Amount := Amount;
        GLEntry."Posting Date" := PostingDate;
        GLEntry.Insert();
    end;
}
