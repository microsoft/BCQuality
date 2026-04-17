codeunit 50212 "Sec Sample SecretHttpClient Good"
{
    procedure Call(ApiKey: SecretText)
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        SecretUri: SecretText;
    begin
        SecretUri := SecretStrSubstNo('https://api.example.com/v1?key=%1', ApiKey);
        Request.SetSecretRequestUri(SecretUri);
        Request.Method('GET');
        Client.Send(Request, Response);
    end;
}
