codeunit 50135 "Perf Sample RecordRef Bad"
{
    procedure BlockCustomer(CustomerNo: Code[20])
    var
        RecRef: RecordRef;
        PkRef: KeyRef;
        NoRef: FieldRef;
        BlockedRef: FieldRef;
    begin
        RecRef.Open(Database::Customer);
        PkRef := RecRef.KeyIndex(1);
        NoRef := PkRef.FieldIndex(1);
        NoRef.SetRange(CustomerNo);
        if not RecRef.FindFirst() then
            exit;
        BlockedRef := RecRef.Field(54);
        BlockedRef.Value(2);
        RecRef.Modify(true);
    end;
}
