page 50102 "Project Task API"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'jobs';
    APIVersion = 'v1.0';
    EntityName = 'projectTask';
    EntitySetName = 'projectTasks';
    SourceTable = "Project Task";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(remainingHours; RemainingHoursCalc) { }
                field(hoursUsed; Rec."Hours Used") { }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Hours Used");
        RemainingHoursCalc := Rec."Budgeted Hours" - Rec."Hours Used";
    end;

    var
        RemainingHoursCalc: Decimal;
}
