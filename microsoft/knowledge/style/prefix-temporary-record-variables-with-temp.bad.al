codeunit 51105 "Style Sample TempPrefix Bad"
{
    procedure BuildWorkingSet()
    var
        WIPBuffer: Record "Job WIP Buffer" temporary;
        Customer: Record Customer;
    begin
        // Call sites read as persistent. A reviewer cannot tell at a glance
        // whether DeleteAll hits the database or the in-memory buffer.
        WIPBuffer.DeleteAll();
        if Customer.FindSet() then
            repeat
                WIPBuffer.Init();
                WIPBuffer.Insert();
            until Customer.Next() = 0;
    end;
}
