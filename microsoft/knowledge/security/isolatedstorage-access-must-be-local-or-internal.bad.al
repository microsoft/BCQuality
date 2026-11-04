codeunit 50216 "Sec Sample IsoStorage Bad"
{
    Access = Public;

    procedure GetApiKey(): SecretText
    var
        ApiKey: SecretText;
    begin
        if IsolatedStorage.Contains('ApiKey', DataScope::Module) then
            IsolatedStorage.Get('ApiKey', DataScope::Module, ApiKey);
        exit(ApiKey);
    end;

    procedure SetApiKey(NewKey: SecretText)
    begin
        IsolatedStorage.SetEncrypted('ApiKey', NewKey, DataScope::Module);
    end;
}
