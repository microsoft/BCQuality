codeunit 50207 "Sec Sample HardcodedSecret Bad"
{
    var
        HardcodedApiKeyLbl: Label 'sk-live-1234567890abcdef', Locked = true;

    procedure GetApiKey(): Text
    begin
        exit(HardcodedApiKeyLbl);
    end;
}
