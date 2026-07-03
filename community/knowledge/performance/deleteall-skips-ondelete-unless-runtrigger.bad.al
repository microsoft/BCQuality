codeunit 50130 "Purge Orders Bad Sample"
{
    procedure PurgeCancelledLines(var SalesLine: Record "Sales Line")
    begin
        // Assumes DeleteAll fires OnDelete and cascades to reservation entries
        // and item applications. It does not: parameterless DeleteAll() is
        // DeleteAll(false) and skips OnDelete, so the rows vanish but their
        // dependent records are orphaned.
        SalesLine.DeleteAll();
    end;
}
