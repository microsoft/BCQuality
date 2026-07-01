codeunit 50124 "Sales Line Guard Bad Sample"
{
    // A throw here executes synchronously inside the transaction of the write
    // that fired the event. With no per-record savepoint, it rolls back ALL
    // uncommitted work since the last COMMIT — the entire batch, not just this
    // line. One bad row discards every row imported before it.
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertSalesLine(var Rec: Record "Sales Line")
    begin
        if Rec.Quantity <= 0 then
            Rec.FieldError(Quantity, 'must be greater than zero');
    end;
}
