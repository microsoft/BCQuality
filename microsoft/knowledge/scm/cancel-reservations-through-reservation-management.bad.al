namespace BCQuality.SCM.Samples;

using Microsoft.Inventory.Tracking;
using Microsoft.Sales.Document;

codeunit 50106 "SCM Cancel Reservation Bad"
{
    procedure CancelSalesReservation(ReservationEntryNo: Integer)
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ReservationEntry.Get(ReservationEntryNo, false);
        ReservationEntry.TestField("Source Type", Database::"Sales Line");
        ReservationEntry.TestField("Reservation Status", ReservationEntry."Reservation Status"::Reservation);

        ReservationEntry.Delete(true);
    end;
}
