// Demonstration-only AL. Not compiled by CI; illustrates the article.
table 50226 "Reservation Entry Bad Sample"
{
    fields
    {
        field(1; "Entry No."; Integer) { }
        field(2; "Item No."; Code[20]) { }
        field(3; Quantity; Decimal) { }
        field(4; Reserved; Boolean) { }
    }
    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}

codeunit 50227 "Reservation Post Bad Sample"
{
    procedure Reserve(var ReservationEntry: Record "Reservation Entry Bad Sample")
    begin
        // Anti-pattern: the operation exposes no OnBefore/OnAfter seam, and the
        // logic that should be the routine's own work lives in the event body
        // below instead. Partners must overwrite this routine to change it.
        OnReserve(ReservationEntry);
    end;

    // Anti-pattern: business logic inside an integration-event publisher. A
    // publisher must be a thin, empty hook; logic placed here runs on every
    // raise and cannot be overridden, which defeats the event entirely.
    [IntegrationEvent(false, false)]
    local procedure OnReserve(var ReservationEntry: Record "Reservation Entry Bad Sample")
    begin
        ReservationEntry.Reserved := true;
        ReservationEntry.Modify(true);
    end;
}
