codeunit 50122 "Contoso Jnl.-Post Batch"
{
    // Check and Post responsibilities are conflated into Post Batch, and
    // Post Line reads the Journal table directly — it can no longer be
    // called on its own by a document posting routine.
    procedure PostBatch(var JnlLine: Record "Contoso Journal Line")
    begin
        if JnlLine.FindSet() then
            repeat
                JnlLine.TestField("Posting Date"); // Check Line's job
                PostLine(JnlLine);
            until JnlLine.Next() = 0;
    end;

    local procedure PostLine(var JnlLine: Record "Contoso Journal Line")
    var
        LedgerEntry: Record "Contoso Ledger Entry";
    begin
        LedgerEntry.Init();
        LedgerEntry.TransferFields(JnlLine);
        LedgerEntry.Insert(true);
        JnlLine.Delete(); // touches the Journal table — no longer reusable elsewhere
    end;
}

page 50120 "Contoso Journal"
{
    PageType = Worksheet;
    SourceTable = "Contoso Journal Line";

    actions
    {
        area(Processing)
        {
            action(Post)
            {
                trigger OnAction()
                var
                    PostBatch: Codeunit "Contoso Jnl.-Post Batch";
                begin
                    // Calls -Post Batch directly — no confirmation wrapper,
                    // and this codeunit can never be driven unattended.
                    PostBatch.PostBatch(Rec);
                end;
            }
        }
    }
}
