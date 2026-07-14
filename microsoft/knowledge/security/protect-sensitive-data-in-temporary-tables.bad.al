codeunit 50100 "Customer Temp Processor"
{
    // Global temporary buffer - survives across procedure calls, carries values
    // to unrelated callers that may have no right to see them.
    var
        GlobalTempCustomer: Record Customer temporary;

    procedure LoadCustomersForExport(FilterText: Text)
    var
        Customer: Record Customer;
    begin
        // No ReadPermission check before populating.
        Customer.SetFilter("No.", FilterText);
        if Customer.FindSet() then
            repeat
                GlobalTempCustomer := Customer;
                GlobalTempCustomer.Insert();
            until Customer.Next() = 0;

        ExportBuffer();
        // No DeleteAll. Data remains in the global for the lifetime of the codeunit.
    end;

    local procedure ExportBuffer()
    begin
    end;
}
