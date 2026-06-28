// Demonstration-only AL. Not compiled by CI; illustrates the article.
table 50224 "Reservation Entry Sample"
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

codeunit 50225 "Reservation Post Good Sample"
{
    procedure Reserve(var ReservationEntry: Record "Reservation Entry Sample")
    var
        IsHandled: Boolean;
    begin
        OnBeforeReserve(ReservationEntry, IsHandled);
        if IsHandled then
            exit;

        ReservationEntry.Reserved := true;
        ReservationEntry.Modify(true);

        OnAfterReserve(ReservationEntry);
    end;

    // Thin publishers: empty bodies, the calling routine owns the logic.
    [IntegrationEvent(false, false)]
    local procedure OnBeforeReserve(var ReservationEntry: Record "Reservation Entry Sample"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReserve(var ReservationEntry: Record "Reservation Entry Sample")
    begin
    end;
}
