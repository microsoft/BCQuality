codeunit 51109 "Style Sample NamedInvoke Bad"
{
    procedure Example(var SalesShptLine: Record "Sales Shipment Line")
    begin
        // Numeric ID. The reader has to look up 525 and 206 to know what is called.
        // If either object is renumbered in a future release, this call silently retargets.
        Page.RunModal(525, SalesShptLine);
        Report.Run(206, true);
    end;
}
