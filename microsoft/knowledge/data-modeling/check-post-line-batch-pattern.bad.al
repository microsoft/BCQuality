codeunit 50101 "Meter Jnl.-Post"
{
    procedure Post(var MeterJnlLine: Record "Meter Journal Line")
    var
        MeterLedgEntry: Record "Meter Ledger Entry";
    begin
        // Validation, Journal access, and posting all mixed in one routine.
        if not Confirm('Post journal lines?') then
            exit;

        if MeterJnlLine.FindSet() then
            repeat
                if MeterJnlLine.Quantity = 0 then
                    Error('Quantity must not be zero.');

                MeterLedgEntry.Init();
                MeterLedgEntry.TransferFields(MeterJnlLine);
                MeterLedgEntry.Insert();
                MeterJnlLine.Delete();
            until MeterJnlLine.Next() = 0;
    end;
}
