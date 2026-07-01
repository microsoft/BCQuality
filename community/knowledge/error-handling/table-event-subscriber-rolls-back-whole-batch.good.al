codeunit 50124 "Batch Import Good Sample"
{
    procedure ImportAll(var StagingLine: Record "Sales Line")
    var
        FailedCount: Integer;
    begin
        if StagingLine.FindSet() then
            repeat
                // Isolate each record behind a Codeunit.Run boundary: a failure
                // inside the run rolls back only that record's work, and the
                // batch continues instead of discarding everything.
                if not Codeunit.Run(Codeunit::"Batch Import One Line", StagingLine) then
                    FailedCount += 1;
            until StagingLine.Next() = 0;

        if FailedCount > 0 then
            Message('%1 line(s) were skipped; the rest were imported.', FailedCount);
    end;
}

codeunit 50125 "Batch Import One Line"
{
    TableNo = "Sales Line";

    trigger OnRun()
    begin
        // Validation lives here. If it throws, only this line rolls back,
        // because the caller wrapped the call in Codeunit.Run.
        Rec.TestField("No.");
        Rec.TestField(Quantity);
        Rec.Insert(true);
    end;
}
