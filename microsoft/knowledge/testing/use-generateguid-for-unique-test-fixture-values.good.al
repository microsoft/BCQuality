codeunit 50132 "Sample Customer Type Library"
{
    var
        LibraryUtility: Codeunit "Library - Utility";

    procedure CreateCustomerType(var CustomerType: Record "Customer Type")
    begin
        CustomerType.Init();
        // Code is shorter than GenerateGUID()'s 10 characters, and this field's
        // uniqueness matters, so use GenerateRandomCodeWithLength: it opens the
        // real (non-temporary) table and loops until the value doesn't collide.
        // GenerateRandomCode would not do this — it opens the table as temporary,
        // so its own emptiness check never inspects real rows.
        CustomerType.Code :=
            LibraryUtility.GenerateRandomCodeWithLength(CustomerType.FieldNo(Code), Database::"Customer Type", MaxStrLen(CustomerType.Code));
        // Description is long enough to hold the full GenerateGUID() value
        // untruncated, and only needs to be incidental, not verified-unique.
        CustomerType.Description := CopyStr(LibraryUtility.GenerateGUID(), 1, MaxStrLen(CustomerType.Description));
        CustomerType.Insert(true);
    end;
}
