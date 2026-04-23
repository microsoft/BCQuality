codeunit 50904 "Privacy Sample Consent Good"
{
    procedure SyncToPartner(var Customer: Record Customer)
    var
        PrivacyNotice: Codeunit "Privacy Notice";
        Client: HttpClient;
        Content: HttpContent;
        Response: HttpResponseMessage;
        PartnerNoticeIdTok: Label 'Contoso-PartnerSync', Locked = true;
        ConsentRequiredErr: Label 'Consent is required before syncing to the external partner.';
    begin
        if PrivacyNotice.GetPrivacyNoticeApprovalState(PartnerNoticeIdTok, false) <>
           "Privacy Notice Approval State"::Agreed
        then
            Error(ConsentRequiredErr);

        Content.WriteFrom(Customer."No.");
        Client.Post('https://partner.example.com/sync', Content, Response);
    end;
}
