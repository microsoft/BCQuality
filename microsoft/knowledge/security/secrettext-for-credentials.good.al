codeunit 50207 "Sec Sample SecretText Good"
{
    procedure CallExternalApi(ApiKey: SecretText)
    var
        HttpClient: HttpClient;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
    begin
        Headers := HttpClient.DefaultRequestHeaders();
        Headers.Add('X-Api-Key', ApiKey);
        HttpClient.Get('https://api.example.com/data', Response);
    end;
}
