codeunit 50100 "Partner API Client"
{
    procedure FetchOrders(var Response: Text): Boolean
    var
        OAuth2: Codeunit OAuth2;
        HttpClient: HttpClient;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        AccessToken: SecretText;
        Scopes: List of [Text];
    begin
        Scopes.Add('https://partner.example.com/.default');

        // Client-credentials flow for service-to-service. Tokens expire and rotate
        // on their own schedule; secret and client id are retrieved from IsolatedStorage.
        if not OAuth2.AcquireTokenWithClientCredentials(
                 GetClientIdFromIsolatedStorage(),
                 GetClientSecretFromIsolatedStorage(),
                 'https://login.example.com/tenantid/oauth2/v2.0/token',
                 '',
                 Scopes,
                 AccessToken)
        then
            exit(false);

        HttpRequest.SetRequestUri('https://partner.example.com/orders');
        HttpRequest.Method('GET');
        HttpRequest.GetHeaders().Add('Authorization', SecretStrSubstNo('Bearer %1', AccessToken));

        if not HttpClient.Send(HttpRequest, HttpResponse) then
            exit(false);

        HttpResponse.Content.ReadAs(Response);
        exit(HttpResponse.IsSuccessStatusCode);
    end;

    local procedure GetClientIdFromIsolatedStorage(): Text
    begin
    end;

    local procedure GetClientSecretFromIsolatedStorage(): SecretText
    begin
    end;
}
