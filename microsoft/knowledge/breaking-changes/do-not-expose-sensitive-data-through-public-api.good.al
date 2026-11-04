codeunit 50320 "Payment Client Good"
{
    Access = Public;

    var
        BearerFormatTok: Label 'Bearer %1', Locked = true;

    procedure GetAuthorizationHeader(AccessToken: SecretText): SecretText
    begin
        exit(SecretStrSubstNo(BearerFormatTok, AccessToken));
    end;
}
