codeunit 50100 "Http Platform Failure Good"
{
    procedure GetCustomer(CustomerId: Guid): Text
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        ResponseText: Text;
    begin
        if not Client.Get(
             StrSubstNo('https://api.example.com/customers/%1', CustomerId),
             Response)
        then
            Error('The customer service could not be reached.');

        Response.Content().ReadAs(ResponseText);
        exit(ResponseText);
    end;
}