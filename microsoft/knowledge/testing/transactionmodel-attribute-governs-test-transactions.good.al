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
    var
        PostingRoutine: Codeunit "Posting Routine With Commit";
    begin
        PostingRoutine.PostCustomer();
    end;
}

codeunit 50155 "Posting Routine With Commit"
{
    procedure PostCustomer()
    var
        Customer: Record Customer;
    begin
        Customer.Init();
        Customer."No." := 'T-COMMIT';
        Customer.Insert(true);
        Commit();
    end;
}
