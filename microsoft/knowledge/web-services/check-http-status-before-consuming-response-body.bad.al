codeunit 50100 "HTTP Status Handling Bad"
{
    procedure GetCustomer(CustomerId: Guid): JsonObject
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        CustomerJson: JsonObject;
        ResponseText: Text;
    begin
        if not Client.Get(
             StrSubstNo('https://api.example.com/customers/%1', CustomerId),
             Response)
        then
            Error('The customer service could not be reached.');

        // A completed request can still contain a 4xx or 5xx error document.
        Response.Content().ReadAs(ResponseText);
        CustomerJson.ReadFrom(ResponseText);
        exit(CustomerJson);
    end;
}