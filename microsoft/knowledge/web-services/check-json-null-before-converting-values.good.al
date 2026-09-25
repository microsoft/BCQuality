codeunit 50172 "Contact Payload Reader Good"
{
    procedure ApplyPayload(var Contact: Record Contact; Payload: JsonObject)
    var
        EmailAddress: Text;
    begin
        if TryGetText(Payload, 'email', EmailAddress) then
            Contact.Validate("E-Mail", CopyStr(EmailAddress, 1, MaxStrLen(Contact."E-Mail")));
        Contact.Modify(true);
    end;

    local procedure TryGetText(Payload: JsonObject; PropertyName: Text; var Value: Text): Boolean
    var
        Token: JsonToken;
    begin
        if not Payload.Get(PropertyName, Token) then
            exit(false);
        if not Token.IsValue() then
            Error(NotAValueErr, PropertyName);
        if Token.AsValue().IsNull() then
            exit(false);
        Value := Token.AsValue().AsText();
        exit(true);
    end;

    var
        NotAValueErr: Label 'The property %1 must contain a single value.', Comment = '%1 = JSON property name';
}
