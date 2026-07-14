codeunit 50209 "Sec Sample SecretHttp Good"
{
    procedure CallApiWithSecretUri(ApiKey: SecretText)
    var
        HttpClient: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        SecretUri: SecretText;
    begin
        SecretUri := SecretStrSubstNo('https://api.example.com/data?key=%1', ApiKey);
        Request.Method := 'GET';
        Request.SetSecretRequestUri(SecretUri);
        HttpClient.Send(Request, Response);
    end;

    procedure CallApiWithAccessToken(AccessToken: SecretText)
    var
        HttpClient: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
        AuthHeader: SecretText;
        AuthorizationHeaderMissingErr: Label 'Authorization header missing.';
    begin
        Request.Method := 'GET';
        Request.SetRequestUri('https://api.example.com/data');
        Request.GetHeaders(Headers);
        AuthHeader := SecretStrSubstNo('Token %1', AccessToken);
        Headers.Add('Authorization', AuthHeader);
        if not Headers.ContainsSecret('Authorization') then
            Error(AuthorizationHeaderMissingErr);
        HttpClient.Send(Request, Response);
    end;
}
