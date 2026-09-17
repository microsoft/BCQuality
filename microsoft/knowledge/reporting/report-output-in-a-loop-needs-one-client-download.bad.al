codeunit 50106 "Download Customer Reports"
{
    procedure DownloadReports(var Customer: Record Customer)
    var
        CustomerView: Record Customer;
    begin
        if Customer.FindSet() then
            repeat
                CustomerView := Customer;
                CustomerView.SetRecFilter();
                Report.Run(Report::"Customer - List", false, false, CustomerView);
            until Customer.Next() = 0;
    end;
}