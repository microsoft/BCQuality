codeunit 50208 "Sec Sample SecretText Bad"
{
    procedure CallExternalApi()
    var
        ApiKey: SecretText;
        HttpClient: HttpClient;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
    begin
        ApiKey := GetApiKey();
        Headers := HttpClient.DefaultRequestHeaders();
        Headers.Add('X-Api-Key', ApiKey);
        HttpClient.Get('https://api.example.com/data', Response);
    end;

    [NonDebuggable]
    local procedure GetApiKey(): Text
    begin
        exit('example-source-credential');
    end;
}
