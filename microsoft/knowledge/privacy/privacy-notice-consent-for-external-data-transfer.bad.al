codeunit 50217 "Privacy Sample Consent Bad"
{
    procedure SendDataToExternalService(Customer: Record Customer)
    var
        HttpClient: HttpClient;
        Content: HttpContent;
        Payload: JsonObject;
        PayloadText: Text;
        Response: HttpResponseMessage;
    begin
        Payload.Add('email', Customer."E-Mail");
        Payload.Add('name', Customer.Name);
        Payload.WriteTo(PayloadText);
        Content.WriteFrom(PayloadText);
        HttpClient.Post('https://api.externalservice.com/sync', Content, Response);
    end;
}
