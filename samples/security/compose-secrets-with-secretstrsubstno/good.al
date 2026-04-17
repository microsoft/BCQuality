codeunit 50214 "Sec Sample SecretCompose Good"
{
    procedure BuildAuthHeader(Token: SecretText) AuthHeader: SecretText
    begin
        AuthHeader := SecretStrSubstNo('Bearer %1', Token);
    end;
}
