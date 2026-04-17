codeunit 50221 "Sec Sample Timeout Bad"
{
    procedure CallExternal()
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
    begin
        // No Timeout set; a hung endpoint stalls the caller.
        Client.Get('https://api.example.com/data', Response);
    end;
}
