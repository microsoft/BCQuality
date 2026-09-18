report 50105 "Customer Entry Review"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
            trigger OnAfterGetRecord()
            var
                EntryNo: Integer;
            begin
                repeat
                    EntryNo += 1;
                    if EntryNo = 5 then
                        CurrReport.Break();
                until EntryNo = 10;

                MarkCustomerReviewed();
            end;
        }
    }

    local procedure MarkCustomerReviewed()
    begin
        ReviewedCustomerCount += 1;
    end;

    var
        ReviewedCustomerCount: Integer;
}