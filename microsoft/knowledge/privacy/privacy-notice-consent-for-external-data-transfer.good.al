codeunit 50216 "Privacy Sample Consent Good"
{
    var
        ExternalSyncNoticeIdLbl: Label 'CONTOSO-EXTERNAL-SYNC', Locked = true;
        ExternalSyncNameLbl: Label 'Contoso External Sync', Locked = true;
        PrivacyTermsUrlLbl: Label 'https://contoso.example/privacy', Locked = true;

    internal procedure RegisterPrivacyNotice()
    var
        PrivacyNotice: Codeunit "Privacy Notice";
    begin
        PrivacyNotice.CreatePrivacyNotice(
            ExternalSyncNoticeIdLbl, ExternalSyncNameLbl, PrivacyTermsUrlLbl);
    end;

    procedure SendDataToExternalService(Customer: Record Customer)
    var
        PrivacyNotice: Codeunit "Privacy Notice";
        HttpClient: HttpClient;
        Content: HttpContent;
        Payload: JsonObject;
        PayloadText: Text;
        Response: HttpResponseMessage;
        PrivacyConsentRequiredErr: Label 'Privacy notice consent is required for this integration.';
    begin
        if not PrivacyNotice.ConfirmPrivacyNoticeApproval(ExternalSyncNoticeIdLbl) then
            Error(PrivacyConsentRequiredErr);

        Payload.Add('email', Customer."E-Mail");
        Payload.Add('name', Customer.Name);
        Payload.WriteTo(PayloadText);
        Content.WriteFrom(PayloadText);
        HttpClient.Post('https://api.externalservice.com/sync', Content, Response);
    end;
}
