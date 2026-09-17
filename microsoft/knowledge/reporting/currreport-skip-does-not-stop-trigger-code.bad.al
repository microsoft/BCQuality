report 50100 "Released Customer List"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
            trigger OnAfterGetRecord()
            begin
                if Blocked <> Blocked::" " then
                    CurrReport.Skip();

                CountIncludedCustomer();
            end;
        }
    }

    local procedure CountIncludedCustomer()
    begin
        IncludedCustomerCount += 1;
    end;

    var
        IncludedCustomerCount: Integer;
}