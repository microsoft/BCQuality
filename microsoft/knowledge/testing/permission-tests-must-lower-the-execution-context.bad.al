// The change adds Insert to CUSTOMER EDITOR so that its users can run the setup action.
// No test lowers the execution context to CUSTOMER EDITOR and runs that action.
permissionset 50485 "CUSTOMER EDITOR"
{
    Assignable = true;
    Permissions =
        tabledata Customer = RI,
        codeunit "Protected Setup Action" = X;
}

codeunit 50481 "Protected Setup Action"
{
    trigger OnRun()
    var
        Customer: Record Customer;
    begin
        Customer.Init();
        Customer."No." := 'NO-INSERT';
        Customer.Insert();
    end;
}
