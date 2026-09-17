// Demonstration-only AL. Not compiled by CI; illustrates the article.

// The published context API - the entire public surface of the pattern.
// Any dependent extension may call IsProcessRunning; nothing else is exposed.
codeunit 50540 "Process Context Good Sample"
{
    procedure IsProcessRunning(): Boolean
    var
        IsRunning: Boolean;
    begin
        OnCheckProcessRunning(IsRunning);
        exit(IsRunning);
    end;

    // InternalEvent: only this app can subscribe, which is all the pattern
    // needs. local: only this codeunit can raise it.
    [InternalEvent(false)]
    local procedure OnCheckProcessRunning(var IsRunning: Boolean)
    begin
    end;
}

// The flag - implementation, not API, hence Access = Internal. It stores
// nothing between runs: being bound is the state.
codeunit 50541 "Process Flag Good Sample"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process Context Good Sample", 'OnCheckProcessRunning', '', false, false)]
    local procedure SetProcessRunning(var IsRunning: Boolean)
    begin
        IsRunning := true;
    end;
}

// The app that drives the process claims the context for exactly its own run.
codeunit 50542 "Process Driver Good Sample"
{
    procedure Run(DocumentNo: Code[20])
    var
        ProcessFlag: Codeunit "Process Flag Good Sample";
    begin
        // A fresh instance, bound for exactly this call. If the shared code
        // errors, the stack unwinds and takes the binding with it - nothing to reset.
        BindSubscription(ProcessFlag);
        RunSharedCode(DocumentNo);
    end;

    local procedure RunSharedCode(DocumentNo: Code[20])
    begin
        // A base application report, a posting routine, or any other object
        // that extensions hook into - including a customer's own replacement.
    end;
}

// An extension hooked into that shared code can now ask the question directly
// instead of guessing which process is driving the run. The hook happens to be
// a report extension here; a subscriber on any other shared object is the same.
reportextension 50543 "Shared Report Ext Good Sample" extends "Standard Sales - Invoice"
{
    trigger OnPreReport()
    var
        ProcessContext: Codeunit "Process Context Good Sample";
    begin
        if not ProcessContext.IsProcessRunning() then
            exit;
        // ... behaviour that applies only inside that process ...
    end;
}
