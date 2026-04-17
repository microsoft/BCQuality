codeunit 50209 "Sec Sample IsolatedStorage Bad"
{
    procedure StoreApiKey(NewKey: Text)
    begin
        // Plaintext write to IsolatedStorage is not encrypted at rest.
        IsolatedStorage.Set('ApiKey', NewKey, DataScope::Module);
    end;

    procedure GetApiKey(): Text
    var
        ApiKey: Text;
    begin
        if IsolatedStorage.Get('ApiKey', DataScope::Module, ApiKey) then
            exit(ApiKey);
        exit('');
    end;
}
