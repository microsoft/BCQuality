codeunit 50215 "Sec Sample SecretCompose Bad"
{
    procedure BuildAuthHeader(Token: Text) AuthHeader: Text
    begin
        // Token is Text, so the combined value is plaintext.
        // The whole shape should have used SecretText + SecretStrSubstNo.
        AuthHeader := StrSubstNo('Bearer %1', Token);
    end;
}
