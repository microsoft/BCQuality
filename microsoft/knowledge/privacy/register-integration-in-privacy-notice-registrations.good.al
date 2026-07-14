codeunit 50218 "Privacy Sample Register Integration"
{
    var
        ExternalSyncNoticeIdLbl: Label 'CONTOSO-EXTERNAL-SYNC', Locked = true;
        ExternalSyncNameLbl: Label 'Contoso External Sync', Locked = true;
        PrivacyTermsUrlLbl: Label 'https://contoso.example/privacy', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Privacy Notice", 'OnRegisterPrivacyNotices', '', false, false)]
    local procedure OnRegisterPrivacyNotices(var TempPrivacyNotice: Record "Privacy Notice" temporary)
    begin
        TempPrivacyNotice.Init();
        TempPrivacyNotice.ID := ExternalSyncNoticeIdLbl;
        TempPrivacyNotice."Integration Service Name" := ExternalSyncNameLbl;
        TempPrivacyNotice.Link := PrivacyTermsUrlLbl;
        if not TempPrivacyNotice.Insert() then;
    end;
}
