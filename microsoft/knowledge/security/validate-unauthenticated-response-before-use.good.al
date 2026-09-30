codeunit 50540 "Sec Sample UnauthResp Good"
{
    // The public VAT validation service does not authenticate itself to us (no OAuth, no
    // certificate, plain HTTP), so its response must be validated before it is trusted.
    procedure IsVatNumberValid(RequestedCountryCode: Text; RequestedVatNumber: Text): Boolean
    var
        HttpClient: HttpClient;
        Response: HttpResponseMessage;
        JsonResponse: JsonObject;
        JsonToken: JsonToken;
        Content: Text;
        ResponseCountryCode: Text;
        ResponseVatNumber: Text;
    begin
        HttpClient.Get('http://vat-service.example/check?cc=' + RequestedCountryCode + '&vat=' + RequestedVatNumber, Response);
        if not Response.IsSuccessStatusCode() then
            exit(false);

        Response.Content().ReadAs(Content);

        // 1) Size cap - the platform already buffered the whole body; reject abnormally large payloads.
        if StrLen(Content) > 4096 then
            Error('The VAT validation response exceeded the maximum allowed size and was rejected.');

        // 2) Schema - require the expected scalar fields, not just a truthy flag.
        if not JsonResponse.ReadFrom(Content) then
            Error('The VAT validation response was not in the expected format and was rejected.');
        if not JsonResponse.Get('countryCode', JsonToken) then
            Error('The VAT validation response did not include the requested identifiers and was rejected.');
        ResponseCountryCode := JsonToken.AsValue().AsText();
        if not JsonResponse.Get('vatNumber', JsonToken) then
            Error('The VAT validation response did not include the requested identifiers and was rejected.');
        ResponseVatNumber := JsonToken.AsValue().AsText();

        // 3) Integrity - the echoed identifiers must match the request, so a valid=true payload
        //    with the identifiers stripped cannot be accepted for an arbitrary VAT number.
        if (UpperCase(ResponseCountryCode) <> UpperCase(RequestedCountryCode)) or
           (UpperCase(ResponseVatNumber) <> UpperCase(RequestedVatNumber))
        then
            Error('The VAT validation response did not match the requested identifiers and was rejected.');

        if not JsonResponse.Get('valid', JsonToken) then
            exit(false);
        exit(JsonToken.AsValue().AsBoolean());
    end;
}
