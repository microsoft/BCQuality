codeunit 50100 "HttpClient Holds Locks Bad"
{
    procedure SyncCustomerLastName(var Customer: Record Customer)
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
    begin
        Customer."Search Name" := Customer.Name;
        Customer.Modify(false);
        // Locks from Modify are held for the entire HTTP wait.
        Client.Get(StrSubstNo('https://example.local/sync/%1', Customer."No."), Response);
    end;
}
