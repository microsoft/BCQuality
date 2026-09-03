codeunit 50100 "Login Subscriber IO Bad"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", OnAfterLogin, '', false, false)]
    local procedure OnAfterLogin()
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        GLEntry: Record "G/L Entry";
    begin
        // Blocks UI, API, and job-queue session creation until HTTP and SQL finish.
        Client.Get('https://example.local/warmup', Response);
        GLEntry.SetLoadFields("Entry No.");
        if GLEntry.FindLast() then;
    end;
}
