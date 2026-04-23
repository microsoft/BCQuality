codeunit 50910 "Privacy Sample IS Good"
{
    procedure StoreDeltaUrl(DeltaUrl: Text)
    var
        DeltaKeyTok: Label 'SyncDeltaUrl', Locked = true;
    begin
        // Sensitive delta URL remains encrypted and scoped to the extension.
        IsolatedStorage.SetEncrypted(DeltaKeyTok, DeltaUrl, DataScope::Company);
    end;
}
