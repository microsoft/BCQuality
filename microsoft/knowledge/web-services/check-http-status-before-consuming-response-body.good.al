codeunit 50100 "HTTP Status Handling Good"
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

        if not Response.IsSuccessStatusCode() then
            Error('The customer service returned HTTP status %1.', Response.HttpStatusCode());

        Response.Content().ReadAs(ResponseText);
        CustomerJson.ReadFrom(ResponseText);
        exit(CustomerJson);
    end;
}