// [FEATURE] Customer maintenance
codeunit 50153 "Test Sample TransModel Good"
{
    Subtype = Test;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestLogicThatDoesNotCommit()
    var
        Customer: Record Customer;
    begin
        // [SCENARIO] A customer record is created in the test body
        // [GIVEN] a new customer record
        Customer.Init();
        Customer."No." := 'T-001';
        // [WHEN] the customer record is inserted
        Customer.Insert(true);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure TestLogicThatCommitsInternally()
    var
        PostingRoutine: Codeunit "Posting Routine With Commit";
    begin
        // [SCENARIO] A customer record is created by the customer routine
        // [WHEN] the routine that creates the customer is run
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
