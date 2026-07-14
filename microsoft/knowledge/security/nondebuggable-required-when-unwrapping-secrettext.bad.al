codeunit 50214 "Sec Sample NonDebug Bad"
{
    procedure CallLegacyOnPremisesConsumer(ApiKey: SecretText)
    var
        PlainApiKey: Text;
    begin
        PlainApiKey := ApiKey.Unwrap();
        InvokeLegacyConsumer(PlainApiKey);
    end;

    local procedure InvokeLegacyConsumer(ApiKey: Text)
    begin
    end;
}
