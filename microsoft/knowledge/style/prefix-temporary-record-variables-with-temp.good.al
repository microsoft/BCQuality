codeunit 51104 "Style Sample TempPrefix Good"
{
    procedure BuildWorkingSet()
    var
        TempJobWIPBuffer: Record "Job WIP Buffer" temporary;
        Customer: Record Customer;
    begin
        // Every read site shows whether the variable is temporary.
        TempJobWIPBuffer.DeleteAll();
        if Customer.FindSet() then
            repeat
                TempJobWIPBuffer.Init();
                TempJobWIPBuffer.Insert();
            until Customer.Next() = 0;
    end;
}
