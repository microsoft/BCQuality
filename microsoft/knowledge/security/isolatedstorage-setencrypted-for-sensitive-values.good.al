codeunit 50217 "Sec Sample SetEncrypted Good"
{
    internal procedure StoreApiKey(ApiKeyValue: SecretText)
    var
        StoreApiKeyFailedErr: Label 'The API key could not be stored.';
    begin
        if not IsolatedStorage.SetEncrypted('ApiKey', ApiKeyValue, DataScope::Module) then
            Error(StoreApiKeyFailedErr);
    end;

    local procedure ReadApiKey(var ApiKey: SecretText): Boolean
    begin
        if not IsolatedStorage.Contains('ApiKey', DataScope::Module) then
            exit(false);
        IsolatedStorage.Get('ApiKey', DataScope::Module, ApiKey);
        exit(true);
    end;
}
