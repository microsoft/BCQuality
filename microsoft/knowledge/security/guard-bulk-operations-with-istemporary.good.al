codeunit 50100 "Order Buffer Helper"
{
    procedure ResetStagingBuffer(var OrderBuffer: Record "Sales Header")
    begin
        // The helper is designed for a temporary buffer only. Fail loudly
        // if a caller accidentally passes the real table.
        if not OrderBuffer.IsTemporary() then
            Error('ResetStagingBuffer requires a temporary Sales Header; a persistent record was passed.');

        OrderBuffer.DeleteAll();
    end;
}
