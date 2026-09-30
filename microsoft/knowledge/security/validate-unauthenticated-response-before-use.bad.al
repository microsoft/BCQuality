codeunit 50541 "Sec Sample UnauthResp Bad"
{
    procedure IsVatNumberValid(RequestedCountryCode: Text; RequestedVatNumber: Text): Boolean
    var
        HttpClient: HttpClient;
        Response: HttpResponseMessage;
        JsonResponse: JsonObject;
        JsonToken: JsonToken;
        Content: Text;
    begin
        // Anti-pattern: the endpoint is unauthenticated, yet the response is trusted with no
        // size cap, no schema check, and no request-to-response integrity check.
        HttpClient.Get('http://vat-service.example/check?cc=' + RequestedCountryCode + '&vat=' + RequestedVatNumber, Response);
        Response.Content().ReadAs(Content);
        JsonResponse.ReadFrom(Content);

        // Trusts valid=true for ANY input: a spoofed or MITM response that omits the echoed
        // countryCode/vatNumber is accepted as valid for whatever number was requested.
        if JsonResponse.Get('valid', JsonToken) then
            exit(JsonToken.AsValue().AsBoolean());
        exit(false);
    end;
}
