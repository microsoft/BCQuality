codeunit 50211 "Sec Sample SecretSubst Good"
{
    procedure BuildAuthHeader(Token: SecretText): SecretText
    begin
        exit(SecretStrSubstNo('Token %1', Token));
    end;

    procedure BuildSecretUri(ApiKey: SecretText): SecretText
    begin
        exit(SecretStrSubstNo('https://api.example.com/data?key=%1', ApiKey));
    end;
}
