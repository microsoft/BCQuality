codeunit 50115 "Scheduled Task Duplicate Good"
{
    procedure EnsureCleanupTask()
    var
        TaskId: Guid;
        StoredTaskId: Text;
    begin
        if IsolatedStorage.Get('CleanupTaskId', DataScope::Company, StoredTaskId) then
            if Evaluate(TaskId, StoredTaskId) then
                if TaskScheduler.TaskExists(TaskId) then
                    exit;

        TaskId := TaskScheduler.CreateTask(Codeunit::"Scheduled Cleanup Work Good", 0, true, CompanyName());
        IsolatedStorage.Set('CleanupTaskId', Format(TaskId), DataScope::Company);
    end;
}

codeunit 50116 "Scheduled Cleanup Work Good"
{
    trigger OnRun()
    begin
    end;
}