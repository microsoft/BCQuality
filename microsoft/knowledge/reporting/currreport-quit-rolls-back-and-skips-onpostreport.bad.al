report 50101 "Update Customer Review"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
            trigger OnAfterGetRecord()
            begin
                "Last Date Modified" := Today();
                Modify();

                if Blocked <> Blocked::" " then
                    CurrReport.Quit();
            end;
        }
    }

    trigger OnPostReport()
    begin
        Message(CompletedMsg);
    end;

    var
        CompletedMsg: Label 'Customer review completed.';
}