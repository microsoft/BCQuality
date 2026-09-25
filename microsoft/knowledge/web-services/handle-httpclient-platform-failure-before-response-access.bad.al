codeunit 50100 "Http Platform Failure Bad"
{
    procedure GetCustomer(CustomerId: Guid): Text
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        ResponseText: Text;
        RequestSucceeded: Boolean;
    begin
        RequestSucceeded := Client.Get(
            StrSubstNo('https://api.example.com/customers/%1', CustomerId),
            Response);

        // Response content is unavailable when the platform call failed.
        Response.Content().ReadAs(ResponseText);
        exit(ResponseText);
    end;
}