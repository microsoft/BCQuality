codeunit 51108 "Style Sample NamedInvoke Good"
{
    procedure Example(var SalesShptLine: Record "Sales Shipment Line")
    begin
        // Named invocation: reviewer sees the object, rename of 525 cannot retarget.
        Page.RunModal(Page::"Posted Sales Shipment Lines", SalesShptLine);
        Report.Run(Report::"Sales - Invoice", true);
    end;
}
