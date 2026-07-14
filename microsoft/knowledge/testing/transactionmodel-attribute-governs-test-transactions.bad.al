codeunit 50154 "Test Sample TransModel Bad"
{
    Subtype = Test;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestPostingRoutineAutoRollback()
    var
        PostingRoutine: Codeunit "Posting Routine Commit Bad";
    begin
        // Runtime error: AutoRollback forbids the Commit reached below.
        PostingRoutine.PostCustomer();
    end;
}

codeunit 50156 "Posting Routine Commit Bad"
{
    procedure PostCustomer()
    var
        Customer: Record Customer;
    begin
        Customer.Init();
        Customer."No." := 'T-BADCOMMIT';
        Customer.Insert(true);
        Commit();
    end;
}
