codeunit 50220 "Sec Sample DataScope Bad"
{
    internal procedure StoreCompanyWebhook(WebhookUrl: SecretText)
    begin
        IsolatedStorage.SetEncrypted('WebhookUrl', WebhookUrl, DataScope::Module);
    end;

    local procedure ReadCompanyWebhook(var WebhookUrl: SecretText): Boolean
    begin
        if not IsolatedStorage.Contains('WebhookUrl', DataScope::Company) then
            exit(false);
        IsolatedStorage.Get('WebhookUrl', DataScope::Company, WebhookUrl);
        exit(true);
    end;
}
