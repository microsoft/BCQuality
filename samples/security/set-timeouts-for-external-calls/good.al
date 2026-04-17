codeunit 50220 "Sec Sample Timeout Good"
{
    procedure CallExternal()
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
    begin
        Client.Timeout := 10000; // 10 seconds
        if not Client.Get('https://api.example.com/data', Response) then
            Error('External service is unavailable.');
    end;
}
