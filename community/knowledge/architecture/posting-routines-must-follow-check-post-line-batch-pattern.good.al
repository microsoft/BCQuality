codeunit 50120 "Contoso Jnl.-Check Line"
{
    procedure CheckLine(var JnlLine: Record "Contoso Journal Line")
    begin
        if JnlLine."Line No." = 0 then
            exit; // skip empty lines without error

        JnlLine.TestField("Posting Date");
        JnlLine.TestField(Amount);
    end;
}

codeunit 50121 "Contoso Jnl.-Post Line"
{
    // Operates only on the record passed in — never reads or writes the
    // Journal table itself, so document posting can call this directly.
    procedure PostLine(var JnlLine: Record "Contoso Journal Line")
    var
        LedgerEntry: Record "Contoso Ledger Entry";
    begin
        LedgerEntry.Init();
        LedgerEntry.TransferFields(JnlLine);
        LedgerEntry.Insert(true);
    end;
}

codeunit 50122 "Contoso Jnl.-Post Batch"
{
    // The only one of the three that touches the Journal table.
    procedure PostBatch(var JnlLine: Record "Contoso Journal Line")
    var
        CheckLine: Codeunit "Contoso Jnl.-Check Line";
        PostLine: Codeunit "Contoso Jnl.-Post Line";
    begin
        if JnlLine.FindSet() then
            repeat
                CheckLine.CheckLine(JnlLine);
            until JnlLine.Next() = 0;

        if JnlLine.FindSet() then
            repeat
                PostLine.PostLine(JnlLine);
                JnlLine.Delete();
            until JnlLine.Next() = 0;
    end;
}

codeunit 50123 "Contoso Jnl.-Post (Yes/No)"
{
    // The only entry point a page should call.
    trigger OnRun()
    var
        JnlLine: Record "Contoso Journal Line";
        PostBatch: Codeunit "Contoso Jnl.-Post Batch";
    begin
        if Confirm('Do you want to post the journal lines?') then
            PostBatch.PostBatch(JnlLine);
    end;
}
