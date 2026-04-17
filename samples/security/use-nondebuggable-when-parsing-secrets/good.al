codeunit 50216 "Sec Sample NonDebuggable Good"
{
    [NonDebuggable]
    procedure ParseSessionToken(Response: HttpResponseMessage; var SessionToken: SecretText)
    var
        ResponseText: Text;
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        Response.Content.ReadAs(ResponseText);
        JObject.ReadFrom(ResponseText);
        JObject.Get('access_token', JToken);
        SessionToken := JToken.AsValue().AsText();
    end;
}
