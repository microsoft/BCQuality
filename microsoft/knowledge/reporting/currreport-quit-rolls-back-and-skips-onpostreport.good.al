report 50101 "Update Customer Review"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
            trigger OnAfterGetRecord()
            begin
                if Blocked <> Blocked::" " then
                    Error(BlockedCustomerErr, "No.");

                "Last Date Modified" := Today();
                Modify();
            end;
        }
    }

    trigger OnPostReport()
    begin
        Message(CompletedMsg);
    end;

    var
        BlockedCustomerErr: Label 'Customer %1 is blocked.', Comment = '%1 = customer number';
        CompletedMsg: Label 'Customer review completed.';
}