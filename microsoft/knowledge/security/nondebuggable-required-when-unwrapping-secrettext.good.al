codeunit 50213 "Sec Sample NonDebug Good"
{
    [NonDebuggable]
    procedure CallLegacyOnPremisesConsumer(ApiKey: SecretText)
    var
        PlainApiKey: Text;
    begin
        PlainApiKey := ApiKey.Unwrap();
        InvokeLegacyConsumer(PlainApiKey);
    end;

    [NonDebuggable]
    local procedure InvokeLegacyConsumer(ApiKey: Text)
    begin
        // The on-premises legacy consumer accepts only Text.
    end;
}
