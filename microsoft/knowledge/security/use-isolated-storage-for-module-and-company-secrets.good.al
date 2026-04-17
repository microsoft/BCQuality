codeunit 50208 "Sec Sample IsolatedStorage Good"
{
    procedure StoreApiKey(NewKey: SecretText)
    begin
        IsolatedStorage.SetEncrypted('ApiKey', NewKey, DataScope::Module);
    end;

    procedure TryGetApiKey(var ApiKey: SecretText): Boolean
    begin
        if IsolatedStorage.Contains('ApiKey', DataScope::Module) then
            exit(IsolatedStorage.Get('ApiKey', DataScope::Module, ApiKey));
        exit(false);
    end;
}
