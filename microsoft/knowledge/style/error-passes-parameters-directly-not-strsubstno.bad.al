codeunit 50207 "Sample Error Params Bad"
{
    var
        CustomerNotFoundErr: Label 'Customer %1 does not exist.';

    procedure CheckCustomer(CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        if not Customer.Get(CustomerNo) then
            Error(FormatCustomerError(CustomerNo));
    end;

    local procedure FormatCustomerError(CustomerNo: Code[20]): Text
    begin
        exit(StrSubstNo(CustomerNotFoundErr, CustomerNo));
    end;
}
