codeunit 50218 "Sec Sample Https Good"
{
    procedure CallExternal(Endpoint: Text)
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
    begin
        if not Endpoint.StartsWith('https://') then
            Error('Only HTTPS endpoints are allowed.');
        Client.Get(Endpoint, Response);
    end;
}
