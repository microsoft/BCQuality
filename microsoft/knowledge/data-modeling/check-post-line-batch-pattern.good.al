codeunit 50101 "Meter Jnl.-Post Line"
{
    procedure PostLine(var MeterJnlLine: Record "Meter Journal Line")
    var
        MeterLedgEntry: Record "Meter Ledger Entry";
    begin
        // Writes exactly one ledger entry; never touches the Journal table.
        MeterLedgEntry.Init();
        MeterLedgEntry.TransferFields(MeterJnlLine);
        MeterLedgEntry.Insert();
    end;
}

codeunit 50102 "Meter Jnl.-Post Batch"
{
    procedure PostBatch(var MeterJnlLine: Record "Meter Journal Line")
    var
        CheckLine: Codeunit "Meter Jnl.-Check Line";
        PostLine: Codeunit "Meter Jnl.-Post Line";
    begin
        if MeterJnlLine.FindSet() then
            repeat
                CheckLine.CheckLine(MeterJnlLine);
            until MeterJnlLine.Next() = 0;

        if MeterJnlLine.FindSet() then
            repeat
                PostLine.PostLine(MeterJnlLine);
                MeterJnlLine.Delete();
            until MeterJnlLine.Next() = 0;
    end;
}
