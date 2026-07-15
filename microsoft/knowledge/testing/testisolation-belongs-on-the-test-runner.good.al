codeunit 50450 "Isolated Test Runner Good"
{
    Subtype = TestRunner;
    TestIsolation = Codeunit;
}

codeunit 50451 "Committed Write Test Good"
{
    Subtype = Test;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure TestCommittedWrite()
    var
        Customer: Record Customer;
    begin
        Customer.Init();
        Customer."No." := 'ISOLATED';
        Customer.Insert();
        Commit();
    end;
}
