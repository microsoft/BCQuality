codeunit 50206 "Sec Sample HardcodedSecret Good"
{
    procedure GetApiKey() ApiKey: SecretText
    var
        StoredValue: SecretText;
    begin
        if IsolatedStorage.Contains('ApiKey', DataScope::Module) then
            if IsolatedStorage.Get('ApiKey', DataScope::Module, StoredValue) then
                exit(StoredValue);
        Error('API key is not configured.');
    end;
}
