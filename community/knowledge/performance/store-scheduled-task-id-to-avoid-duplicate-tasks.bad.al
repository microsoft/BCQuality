codeunit 50115 "Scheduled Task Duplicate Bad"
{
    procedure EnsureCleanupTask()
    begin
        // Every call creates another task for the same cleanup work.
        TaskScheduler.CreateTask(Codeunit::"Scheduled Cleanup Work Bad", 0, true, CompanyName());
    end;
}

codeunit 50116 "Scheduled Cleanup Work Bad"
{
    trigger OnRun()
    begin
    end;
}