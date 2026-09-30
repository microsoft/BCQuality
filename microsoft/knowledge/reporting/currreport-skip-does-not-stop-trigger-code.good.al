report 50100 "Released Customer List"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
            trigger OnAfterGetRecord()
            begin
                if Blocked <> Blocked::" " then begin
                    CurrReport.Skip();
                    exit;
                end;

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