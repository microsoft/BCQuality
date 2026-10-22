codeunit 50206 "Sample Error Params Good"
{
    var
        CustomerNotFoundErr: Label 'Customer %1 does not exist.';
        OptionsLbl: Label 'Preview,Print';
        InstructionLbl: Label 'Choose an output for customer %1.';
        ContinueQst: Label 'Continue for customer %1?';

    procedure CheckCustomer(CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        if not Customer.Get(CustomerNo) then
            Error(CustomerNotFoundErr, CustomerNo);
    end;

    procedure ChooseOutput(CustomerNo: Code[20]): Integer
    begin
        if not Confirm(ContinueQst, false, CustomerNo) then
            exit(0);
        exit(StrMenu(OptionsLbl, 1, StrSubstNo(InstructionLbl, CustomerNo)));
    end;
}
