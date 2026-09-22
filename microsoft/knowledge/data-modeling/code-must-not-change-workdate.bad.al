codeunit 50101 "Batch Job Runner"
{
    procedure AdvanceToNextBusinessDay()
    begin
        // Anti-pattern: repurposes the user's session WorkDate as a
        // scratch variable for unrelated business logic.
        WorkDate(CalcDate('<1D>', WorkDate()));
    end;
}
