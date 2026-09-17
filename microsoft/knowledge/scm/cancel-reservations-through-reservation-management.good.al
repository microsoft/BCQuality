codeunit 50107 "SCM Cancel Reservation Good"
{
    procedure CancelSalesReservation(ReservationEntryNo: Integer)
    var
        ReservationEntry: Record "Reservation Entry";
        ReservationEngineMgt: Codeunit "Reservation Engine Mgt.";
    begin
        ReservationEntry.Get(ReservationEntryNo, false);
        ReservationEntry.TestField("Source Type", Database::"Sales Line");
        ReservationEntry.TestField("Reservation Status", ReservationEntry."Reservation Status"::Reservation);

        ReservationEngineMgt.CancelReservation(ReservationEntry);
    end;
}
