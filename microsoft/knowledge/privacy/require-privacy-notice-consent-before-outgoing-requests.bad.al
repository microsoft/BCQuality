codeunit 50905 "Privacy Sample Consent Bad"
{
    procedure SyncToPartner(var Customer: Record Customer)
    var
        Client: HttpClient;
        Content: HttpContent;
        Response: HttpResponseMessage;
    begin
        // Customer email and name sent externally with no Privacy Notice check
        // anywhere in the reachable code path.
        Content.WriteFrom(Customer."E-Mail");
        Client.Post('https://partner.example.com/sync', Content, Response);
    end;
}
