codeunit 50212 "Sec Sample SecretSubst Bad"
{
    procedure BuildAuthHeader(Token: Text): Text
    begin
        exit(StrSubstNo('Token %1', Token));
    end;

    procedure BuildSecretUri(ApiKey: Text): Text
    begin
        exit(StrSubstNo('https://api.example.com/data?key=%1', ApiKey));
    end;

    procedure BuildBrokenAuthHeader(Token: SecretText): SecretText
    begin
        exit(SecretStrSubstNo('Token', Token));
    end;
}
