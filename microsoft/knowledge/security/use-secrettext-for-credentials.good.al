codeunit 50210 "Sec Sample SecretText Good"
{
    procedure SendAuthenticatedRequest(BearerToken: SecretText)
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        Response: HttpResponseMessage;
        AuthValue: SecretText;
    begin
        AuthValue := SecretStrSubstNo('Bearer %1', BearerToken);
        Client.DefaultRequestHeaders.Add('Authorization', AuthValue);
        Client.Get('https://api.example.com/data', Response);
    end;
}
