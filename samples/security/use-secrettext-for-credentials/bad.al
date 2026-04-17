codeunit 50211 "Sec Sample SecretText Bad"
{
    procedure SendAuthenticatedRequest(BearerToken: Text)
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        AuthValue: Text;
    begin
        AuthValue := 'Bearer ' + BearerToken;
        Client.DefaultRequestHeaders.Add('Authorization', AuthValue);
        Client.Get('https://api.example.com/data', Response);
    end;
}
