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

    procedure CallApiWithBearer(BearerToken: Text)
    var
        HttpClient: HttpClient;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
    begin
        Headers := HttpClient.DefaultRequestHeaders();
        Headers.Add('Authorization', StrSubstNo('Bearer %1', BearerToken));
        HttpClient.Get('https://api.example.com/data', Response);
    end;
}
