codeunit 50100 "Rental Period Defaults"
{
    procedure GetPolicyStartDate(): Date
    var
        PolicyStartDate: Date;
    begin
        Evaluate(PolicyStartDate, '01/31/2025');
        exit(PolicyStartDate);
    end;
}