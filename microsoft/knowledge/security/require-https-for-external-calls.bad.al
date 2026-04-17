codeunit 50219 "Sec Sample Https Bad"
{
    procedure CallExternal()
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
    begin
        Client.Get('http://api.example.com/data', Response);
    end;
}
