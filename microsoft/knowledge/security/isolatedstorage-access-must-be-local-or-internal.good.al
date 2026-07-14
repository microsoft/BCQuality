codeunit 50215 "Sec Sample IsoStorage Good"
{
    local procedure GetApiKey(var ApiKey: SecretText): Boolean
    begin
        if not IsolatedStorage.Contains('ApiKey', DataScope::Module) then
            exit(false);
        IsolatedStorage.Get('ApiKey', DataScope::Module, ApiKey);
        exit(true);
    end;

    internal procedure SetApiKey(NewKey: SecretText)
    begin
        IsolatedStorage.SetEncrypted('ApiKey', NewKey, DataScope::Module);
    end;
}
