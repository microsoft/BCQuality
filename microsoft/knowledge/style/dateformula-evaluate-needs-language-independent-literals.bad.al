codeunit 50102 "Bad Review Scheduling"
{
    procedure NextReviewDate(Interval: DateFormula; ReferenceDate: Date): Date
    begin
        if Format(Interval) = '' then
            Evaluate(Interval, '1W');

        exit(CalcDate(Interval, ReferenceDate));
    end;

    procedure NextReviewFromUserInput(UserFormulaText: Text; ReferenceDate: Date): Date
    var
        Interval: DateFormula;
    begin
        Evaluate(Interval, UserFormulaText);
        exit(NextReviewDate(Interval, ReferenceDate));
    end;
}
