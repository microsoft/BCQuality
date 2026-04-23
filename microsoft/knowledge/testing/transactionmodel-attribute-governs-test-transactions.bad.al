codeunit 50154 "Test Sample TransModel Bad"
{
    Subtype = Test;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestPostingRoutineAutoRollback()
    begin
    end;
}
