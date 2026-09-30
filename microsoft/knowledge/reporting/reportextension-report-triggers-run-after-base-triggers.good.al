report 50110 "Customer Export"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
        }
    }

    trigger OnPreReport()
    var
        ExportDate: Date;
    begin
        OnBeforeResolveExportDate(ExportDate);
        if ExportDate = 0D then
            Error(ExportDateRequiredErr);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResolveExportDate(var ExportDate: Date)
    begin
    end;

    var
        ExportDateRequiredErr: Label 'An export date is required.';
}

codeunit 50111 "Customer Export Extension"
{
    [EventSubscriber(ObjectType::Report, Report::"Customer Export", 'OnBeforeResolveExportDate', '', false, false)]
    local procedure SetExportDate(var ExportDate: Date)
    begin
        ExportDate := Today();
    end;
}