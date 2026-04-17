codeunit 50223 "Sec Sample UrlCreds Bad"
{
    procedure Call(ApiKey: Text)
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
    begin
        Client.Get('https://api.example.com/v1/items?api_key=' + ApiKey, Response);
    end;
}
