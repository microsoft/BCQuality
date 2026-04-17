codeunit 50128 "Perf Sample TxnScope Bad"
{
    procedure ImportCustomers(var Source: List of [Text])
    var
        Customer: Record Customer;
        HttpClient: HttpClient;
        HttpResponse: HttpResponseMessage;
        Row: Text;
    begin
        foreach Row in Source do begin
            // external call inside the write transaction
            HttpClient.Get('https://example.com/validate?row=' + Row, HttpResponse);
            Customer.Init();
            // ... populate from Row ...
            Customer.Insert(true);
        end;
    end;
}
