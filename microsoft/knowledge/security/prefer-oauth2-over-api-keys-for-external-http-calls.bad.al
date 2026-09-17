codeunit 50100 "Partner API Client"
{
    procedure FetchOrders(var Response: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        ApiKey: Text;
    begin
        // API key stored as plain Text in a setup table - not IsolatedStorage,
        // not SecretText. Rotation means the admin editing a Text field;
        // a single disclosure exposes every tenant running this extension.
        ApiKey := GetApiKeyFromSetupTable();

        HttpRequest.SetRequestUri('https://partner.example.com/orders');
        HttpRequest.Method('GET');
        HttpRequest.GetHeaders().Add('X-API-Key', ApiKey);

        if not HttpClient.Send(HttpRequest, HttpResponse) then
            exit(false);

        HttpResponse.Content.ReadAs(Response);
        exit(HttpResponse.IsSuccessStatusCode);
    end;

    local procedure GetApiKeyFromSetupTable(): Text
    begin
    end;
}
