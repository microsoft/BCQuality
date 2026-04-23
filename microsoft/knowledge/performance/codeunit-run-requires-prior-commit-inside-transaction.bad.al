codeunit 50147 "Perf Sample OpenTxnRun Bad"
{
    procedure ApplyDiscountToSelection(var Customer: Record Customer)
    var
        ApplyOne: Codeunit "Perf Sample OpenTxnRun Apply";
        RunLog: Record "Custom Run Log";
    begin
        if Customer.FindSet() then
            repeat
                RunLog.Init();
                RunLog."Customer No." := Customer."No.";
                RunLog.Insert();
                if not ApplyOne.Run(Customer) then;
            until Customer.Next() = 0;
    end;
}

codeunit 50148 "Perf Sample OpenTxnRun Apply"
{
    TableNo = Customer;

    trigger OnRun()
    begin
        Rec.Validate("Customer Price Group", 'VIP');
        Rec.Modify(true);
    end;
}
