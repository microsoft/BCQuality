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
        // Temp = false: the loop checks the persisted Payment Terms rows.
        RecRef.Open(Database::"Payment Terms", false, CompanyName());
        FieldRef := RecRef.Field(PaymentTerms.FieldNo(Code));
        repeat
            NewCode := CopyStr(LibraryUtility.GenerateRandomXMLText(MaxStrLen(NewCode)), 1, MaxStrLen(NewCode));
            FieldRef.SetRange(NewCode);
        until RecRef.IsEmpty();
        exit(NewCode);
    end;

    procedure GetFieldFilterFromView(TableNo: Integer; TableView: Text; FieldNo: Integer): Text
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        // Temp = true is correct here: the RecordRef only parses a view and
        // never reads rows.
        RecRef.Open(TableNo, true);
        RecRef.SetView(TableView);
        FieldRef := RecRef.Field(FieldNo);
        exit(FieldRef.GetFilter());
    end;
}
