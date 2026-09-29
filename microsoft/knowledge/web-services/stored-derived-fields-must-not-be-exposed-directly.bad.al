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
                // "Remaining Hours" is a stored field, set inside the
                // OnValidate of "Budgeted Hours" — it goes stale whenever
                // "Hours Used" changes through any other path.
                field(remainingHours; Rec."Remaining Hours") { }
            }
        }
    }
}
