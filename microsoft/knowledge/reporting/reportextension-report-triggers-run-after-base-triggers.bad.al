report 50110 "Customer Export"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
        }
    }

    trigger OnPreReport()
    var
        ExportSetup: Record "Customer Export Setup";
    begin
        ExportSetup.Get();
        ExportSetup.TestField("Export Date");
    end;
}

reportextension 50111 "Customer Export Extension" extends "Customer Export"
{
    trigger OnPreReport()
    var
        ExportSetup: Record "Customer Export Setup";
    begin
        ExportSetup.Get();
        ExportSetup.Validate("Export Date", Today());
        ExportSetup.Modify(true);
    end;
}