codeunit 50217 "Sec Sample NonDebuggable Bad"
{
    // Missing [NonDebuggable]: ResponseText and the extracted token are
    // inspectable in the debugger and in snapshot debug sessions.
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
