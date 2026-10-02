// Test-library-style helper (uses "Library - Utility"); not a Subtype = Test codeunit.
codeunit 50150 "Sample Payment Terms Codes"
{
    procedure GenerateUnusedPaymentTermsCode(): Code[10]
    var
        PaymentTerms: Record "Payment Terms";
        LibraryUtility: Codeunit "Library - Utility";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        NewCode: Code[10];
    begin
        // Temp = true: RecRef is an empty temporary instance, so IsEmpty()
        // is true on the first pass and existing Payment Terms are never seen.
        RecRef.Open(Database::"Payment Terms", true, CompanyName());
        FieldRef := RecRef.Field(PaymentTerms.FieldNo(Code));
        repeat
            NewCode := CopyStr(LibraryUtility.GenerateRandomXMLText(MaxStrLen(NewCode)), 1, MaxStrLen(NewCode));
            FieldRef.SetRange(NewCode);
        until RecRef.IsEmpty();
        exit(NewCode);
    end;
}
