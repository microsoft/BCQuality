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
                StopReview: Boolean;
            begin
                repeat
                    EntryNo += 1;
                    StopReview := EntryNo = 5;
                until StopReview or (EntryNo = 10);

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