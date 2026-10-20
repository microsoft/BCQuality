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

    // No TransactionModel attribute declared at all: the test exercises no Commit
    // call, so it simply runs under the undeclared AutoCommit default. Removing a
    // mismatched explicit attribute like this is a valid fix, not a bug to flag -
    // it does not have to be replaced with an explicit AutoRollback declaration.
    [Test]
    procedure TestLogicThatDoesNotCommitWithNoAttributeDeclared()
    var
        Customer: Record Customer;
    begin
        Customer.Init();
        Customer."No." := 'T-002';
        Customer.Insert(true);
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
