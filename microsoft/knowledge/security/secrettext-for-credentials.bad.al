codeunit 50208 "Sec Sample SecretText Bad"
{
    procedure CallExternalApi()
    var
        ApiKey: Text;
        BearerToken: Text;
        HttpClient: HttpClient;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
    begin
        ApiKey := GetApiKey();
        BearerToken := GetAccessToken();
        Headers := HttpClient.DefaultRequestHeaders();
        Headers.Add('Authorization', 'Bearer ' + BearerToken);
        Headers.Add('X-Api-Key', ApiKey);
        HttpClient.Get('https://api.example.com/data', Response);
    end;

    local procedure GetApiKey(): Text begin end;

    local procedure GetAccessToken(): Text begin end;
}
