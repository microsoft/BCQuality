codeunit 50100 "Login Subscriber IO Good"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", OnAfterLogin, '', false, false)]
    local procedure OnAfterLogin()
    var
        TaskId: Guid;
        StoredId: Text;
    begin
        // Guard to interactive sessions only; background task sessions also raise OnAfterLogin.
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop, ClientType::Tablet, ClientType::Phone]) then
            exit;

        // Idempotent: TaskExists requires the GUID returned by CreateTask, stored across logins.
        if IsolatedStorage.Get('LoginSyncTaskId', DataScope::Company, StoredId) then
            if Evaluate(TaskId, StoredId) then
                if TaskScheduler.TaskExists(TaskId) then
                    exit;

        TaskId := TaskScheduler.CreateTask(Codeunit::"Login Subscriber IO Work", 0, true, CompanyName(), CurrentDateTime() + 60000);
        IsolatedStorage.Set('LoginSyncTaskId', Format(TaskId), DataScope::Company);
    end;
}

codeunit 50101 "Login Subscriber IO Work"
{
    trigger OnRun()
    begin
        // Isolated from session creation: outbound I/O is safe here.
    end;
}
