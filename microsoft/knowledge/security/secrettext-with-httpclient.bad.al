codeunit 50210 "Sec Sample SecretHttp Bad"
{
    procedure CallApiWithSecretInUri(ApiKey: Text)
    var
        HttpClient: HttpClient;
        Response: HttpResponseMessage;
        RequestUri: Text;
    begin
        RequestUri := StrSubstNo('https://api.example.com/data?key=%1', ApiKey);
        HttpClient.Get(RequestUri, Response);
    end;

    procedure CallApiWithAccessToken(AccessToken: Text)
    var
        HttpClient: HttpClient;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
    begin
        Headers := HttpClient.DefaultRequestHeaders();
        Headers.Add('Authorization', StrSubstNo('Token %1', AccessToken));
        HttpClient.Get('https://api.example.com/data', Response);
    end;
}
