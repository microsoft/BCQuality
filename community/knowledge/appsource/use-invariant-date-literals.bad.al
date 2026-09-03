codeunit 50100 "Rental Period Defaults"
{
    procedure GetPolicyStartDate(): Date
    var
        PolicyStartDate: Date;
    begin
        Evaluate(PolicyStartDate, '01/02/2025');
        exit(PolicyStartDate);
    end;
}