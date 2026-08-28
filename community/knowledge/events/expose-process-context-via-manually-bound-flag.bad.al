// Demonstration-only AL. Not compiled by CI; illustrates the article.

// Anti-pattern 1: the context is kept in single-instance state.
codeunit 50545 "Process State Bad Sample"
{
    SingleInstance = true;

    var
        ProcessRunning: Boolean;

    procedure SetProcessRunning(NewProcessRunning: Boolean)
    begin
        ProcessRunning := NewProcessRunning;
    end;

    procedure IsProcessRunning(): Boolean
    begin
        exit(ProcessRunning);
    end;
}

codeunit 50546 "Process Driver Bad Sample"
{
    procedure Run(DocumentNo: Code[20])
    var
        ProcessState: Codeunit "Process State Bad Sample";
    begin
        ProcessState.SetProcessRunning(true);
        RunSharedCode(DocumentNo);
        // An error above never reaches this line. The database writes roll
        // back, the single-instance variable does not: ProcessRunning stays
        // true until the company is closed, so every later run in this session
        // is treated as part of the process.
        ProcessState.SetProcessRunning(false);
    end;

    local procedure RunSharedCode(DocumentNo: Code[20])
    begin
    end;
}

// Anti-pattern 2: the context stays private. Flag and driver look like the
// good sample, but the query is internal, so only the owning app can ever ask.
codeunit 50547 "Process Ctx Bad Sample"
{
    internal procedure IsProcessRunning(): Boolean
    var
        IsRunning: Boolean;
    begin
        OnCheckProcessRunning(IsRunning);
        exit(IsRunning);
    end;

    [InternalEvent(false)]
    local procedure OnCheckProcessRunning(var IsRunning: Boolean)
    begin
    end;
}

reportextension 50548 "Shared Report Ext Bad Sample" extends "Standard Sales - Invoice"
{
    trigger OnPreReport()
    begin
        // No callable query exists, so the extension infers the context from
        // something it hopes only that process does - here, running without a
        // UI. The guess is wrong for every other background run, and breaks
        // silently the first time the owning app changes how it works.
        if GuiAllowed() then
            exit;
        // ... behaviour that was meant to apply only inside that process ...
    end;
}
