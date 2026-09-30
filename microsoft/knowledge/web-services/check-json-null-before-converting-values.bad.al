codeunit 50173 "Contact Payload Reader Bad"
{
    procedure ApplyPayload(var Contact: Record Contact; Payload: JsonObject)
    var
        Token: JsonToken;
    begin
        if Payload.Get('email', Token) then
            Contact.Validate("E-Mail", CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(Contact."E-Mail")));
        Contact.Modify(true);
    end;
}
