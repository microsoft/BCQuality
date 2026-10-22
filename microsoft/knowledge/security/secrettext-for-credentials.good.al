codeunit 50207 "Sec Sample SecretText Good"
{
    procedure CallExternalApi()
    var
        ApiKey: SecretText;
        HttpClient: HttpClient;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
    begin
        ApiKey := RetrieveApiKey();
        Headers := HttpClient.DefaultRequestHeaders();
        Headers.Add('X-Api-Key', ApiKey);
        HttpClient.Get('https://api.example.com/data', Response);
    end;

    [NonDebuggable]
    local procedure RetrieveApiKey(): SecretText
    var
        StoredValue: Text;
    begin
        if not IsolatedStorage.Get('ServiceCredential', DataScope::Module, StoredValue) then
            Error(MissingCredentialErr);
        exit(StoredValue);
    end;

    procedure FindToken(Token: Text; Tokens: List of [Text]): Integer
    begin
        exit(Tokens.IndexOf(Token));
    end;

    var
        MissingCredentialErr: Label 'Configure the service credential before connecting.';
}

codeunit 50209 "Sec Sample Credential Test"
{
    Subtype = Test;

    [Test]
    procedure AcceptMockCredential()
    var
        Credential: Text;
    begin
        Credential := 'fixture-only-credential';
        if not MockAccepts(Credential) then
            Error(MockRejectedErr);
    end;

    local procedure MockAccepts(Credential: Text): Boolean
    begin
        exit(Credential = 'fixture-only-credential');
    end;

    var
        MockRejectedErr: Label 'The mock rejected the fixture value.';
}
