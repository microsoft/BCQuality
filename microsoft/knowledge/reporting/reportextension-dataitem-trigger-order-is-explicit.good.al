report 50103 "Base Customer Export"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
            trigger OnPreDataItem()
            begin
                SetRange(Blocked, Blocked::" ");
                SetRange("Country/Region Code");
            end;
        }
    }
}

reportextension 50104 "Local Customer Export" extends "Base Customer Export"
{
    dataset
    {
        modify(Customer)
        {
            trigger OnAfterPreDataItem()
            begin
                SetFilter("Country/Region Code", '<>%1', '');
            end;
        }
    }
}