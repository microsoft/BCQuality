codeunit 50213 "Sec Sample SecretHttpClient Bad"
{
    procedure Call(ApiKey: Text)
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        FullUrl: Text;
    begin
        FullUrl := 'https://api.example.com/v1?key=' + ApiKey;
        Client.Get(FullUrl, Response);
    end;
}
