codeunit 50452 "Isolated Test Runner Bad"
{
    Subtype = TestRunner;
    TestIsolation = Disabled;
}

codeunit 50453 "Committed Write Test Bad"
{
    Subtype = Test;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure TestCommittedWrite()
    var
        Customer: Record Customer;
    begin
        Customer.Init();
        Customer."No." := 'PERSISTS';
        Customer.Insert();
        Commit();
    end;
}
