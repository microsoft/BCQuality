codeunit 50204 "Sample Locked Label Good"
{
    var
        GetMethodTok: Label 'GET', Locked = true;
        ContentTypeJsonTok: Label 'application/json', Locked = true;
        ApiBaseUrlTok: Label 'https://api.contoso.com/v1', Locked = true;
        TelemetryStartTxt: Label 'Operation started for %1.', Locked = true;
        // Seeded VAT Bus. Posting Group default code: intentionally NOT locked.
        // Each localization layer ships its own translated code and creates the
        // matching master-data record with that same translated code, so
        // translating this Label does not break the lookup.
        XDomesticTxt: Label 'DOMESTIC';
}
