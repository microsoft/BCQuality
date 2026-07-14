codeunit 50134 "Api Credential Good Sample"
{
    procedure StoreApiKey(ApiKey: SecretText)
    begin
        // Credentials live in IsolatedStorage, invisible to record reads, API
        // pages, RapidStart packages, and Excel export.
        IsolatedStorage.SetEncrypted('ExternalApiKey', ApiKey, DataScope::Module);
    end;

    procedure GetApiKey() ApiKey: SecretText
    begin
        if not IsolatedStorage.Get('ExternalApiKey', DataScope::Module, ApiKey) then
            Error('The external API key has not been configured.');
    end;
}
