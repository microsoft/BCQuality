codeunit 50130 "Purge Orders Good Sample"
{
    procedure PurgeCancelledLines(var SalesLine: Record "Sales Line")
    begin
        // These lines have OnDelete cleanup (reservation entries, item
        // application). Pass true so DeleteAll runs OnDelete per record and the
        // cleanup actually happens — the row-by-row cost is accepted on purpose.
        SalesLine.DeleteAll(true);
    end;

    procedure PurgeStagingBuffer(var TempBuffer: Record "Name/Value Buffer" temporary)
    begin
        // No OnDelete logic to run: the fast, set-based form is correct here.
        TempBuffer.DeleteAll();
    end;
}
