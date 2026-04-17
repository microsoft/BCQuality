codeunit 50222 "Sec Sample UrlCreds Good"
{
    procedure Call(ApiKey: SecretText)
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        AuthHeader: SecretText;
    begin
        AuthHeader := SecretStrSubstNo('Bearer %1', ApiKey);
        Client.DefaultRequestHeaders.Add('Authorization', AuthHeader);
        Client.Get('https://api.example.com/v1/items', Response);
    end;
}
