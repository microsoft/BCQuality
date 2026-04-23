codeunit 50153 "Test Sample TransModel Good"
{
    Subtype = Test;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestLogicThatDoesNotCommit()
    var
        Customer: Record Customer;
    begin
        Customer.Init();
        Customer."No." := 'T-001';
        Customer.Insert(true);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure TestLogicThatCommitsInternally()
    begin
    end;
}
