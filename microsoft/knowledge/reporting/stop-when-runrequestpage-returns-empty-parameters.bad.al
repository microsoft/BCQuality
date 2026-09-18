codeunit 50109 "Export Customer Report"
{
    procedure ExportReport()
    var
        TempBlob: Codeunit "Temp Blob";
        ReportOutStream: OutStream;
        RequestPageParameters: Text;
    begin
        RequestPageParameters := Report.RunRequestPage(Report::"Customer - List");
        TempBlob.CreateOutStream(ReportOutStream);
        Report.SaveAs(
            Report::"Customer - List",
            RequestPageParameters,
            ReportFormat::Pdf,
            ReportOutStream);
    end;
}