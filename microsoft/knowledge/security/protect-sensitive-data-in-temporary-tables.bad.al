codeunit 50100 "Customer Temp Processor"
{
    SingleInstance = true;

    var
        TempCachedCustomer: Record Customer temporary;
        ReadDeniedErr: Label 'You do not have permission to read customers.';

    procedure LoadCustomer(CustomerNo: Code[20])
    var
        Customer: Record Customer;
        Loader: Codeunit "Customer Buffer Loader";
    begin
        if not Customer.ReadPermission() then
            Error(ReadDeniedErr);

        TempCachedCustomer.DeleteAll();
        Loader.LoadCustomer(CustomerNo, TempCachedCustomer);
    end;

    procedure GetCachedCustomers(var TempResult: Record Customer temporary)
    begin
        TempResult.Copy(TempCachedCustomer, true);
    end;
}

codeunit 50101 "Customer Buffer Loader"
{
    Access = Internal;
    Permissions = tabledata Customer = r;

    procedure LoadCustomer(CustomerNo: Code[20]; var TempCustomer: Record Customer temporary)
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        TempCustomer := Customer;
        TempCustomer.Insert();
    end;
}
