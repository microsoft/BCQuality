codeunit 50132 "Sample Customer Type Library"
{
    procedure CreateCustomerType(var CustomerType: Record "Customer Type")
    begin
        CustomerType.Init();
        CustomerType.Code := 'TEST001';
        CustomerType.Description := 'Test Customer Type';
        CustomerType.Insert(true);
    end;
}
