codeunit 50106 "Download Customer Reports"
{
    procedure DownloadReports(var Customer: Record Customer)
    var
        CustomerView: Record Customer;
        CustomerList: Report "Customer - List";
        DataCompression: Codeunit "Data Compression";
        ReportTempBlob: Codeunit "Temp Blob";
        ZipTempBlob: Codeunit "Temp Blob";
        ReportInStream: InStream;
        ZipInStream: InStream;
        ReportOutStream: OutStream;
        ZipOutStream: OutStream;
        ZipFileName: Text;
    begin
        DataCompression.CreateZipArchive();
        if Customer.FindSet() then
            repeat
                Clear(CustomerList);
                Clear(ReportTempBlob);
                CustomerView := Customer;
                CustomerView.SetRecFilter();
                CustomerList.SetTableView(CustomerView);
                ReportTempBlob.CreateOutStream(ReportOutStream);
                CustomerList.SaveAs('', ReportFormat::Pdf, ReportOutStream);
                ReportTempBlob.CreateInStream(ReportInStream);
                DataCompression.AddEntry(ReportInStream, Customer."No." + '.pdf');
            until Customer.Next() = 0;

        ZipTempBlob.CreateOutStream(ZipOutStream);
        DataCompression.SaveZipArchive(ZipOutStream);
        DataCompression.CloseZipArchive();
        ZipTempBlob.CreateInStream(ZipInStream);
        ZipFileName := 'CustomerReports.zip';
        DownloadFromStream(ZipInStream, '', '', '*.zip', ZipFileName);
    end;
}