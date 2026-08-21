page 50100 "Cue Background Task Good"
{
    PageType = CardPart;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            cuegroup(Group)
            {
                field(OpenOrders; OpenOrderCount)
                {
                    Caption = 'Open Sales Orders';
                }
            }
        }
    }

    var
        OpenOrderCount: Integer;
        TaskId: Integer;

    trigger OnAfterGetCurrRecord()
    var
        Args: Dictionary of [Text, Text];
    begin
        CurrPage.EnqueueBackgroundTask(TaskId, Codeunit::"Cue Open Order Count", Args);
    end;

    trigger OnPageBackgroundTaskCompleted(CompletedTaskId: Integer; Results: Dictionary of [Text, Text])
    begin
        if Results.ContainsKey('Count') then
            Evaluate(OpenOrderCount, Results.Get('Count'));
    end;
}

codeunit 50100 "Cue Open Order Count"
{
    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
        Results: Dictionary of [Text, Text];
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        Results.Add('Count', Format(SalesHeader.CountApprox()));
        Page.SetBackgroundTaskResult(Results);
    end;
}
