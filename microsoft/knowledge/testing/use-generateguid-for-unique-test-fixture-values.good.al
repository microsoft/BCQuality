codeunit 50132 "Sample Customer Type Library"
{
    var
        LibraryUtility: Codeunit "Library - Utility";

    procedure CreateCustomerType(var CustomerType: Record "Customer Type")
    begin
        CustomerType.Init();
        CustomerType.Code := CopyStr(LibraryUtility.GenerateGUID(), 1, MaxStrLen(CustomerType.Code));
        CustomerType.Description := CopyStr(LibraryUtility.GenerateGUID(), 1, MaxStrLen(CustomerType.Description));
        CustomerType.Insert(true);
    end;
}
