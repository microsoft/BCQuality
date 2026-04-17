permissionset 50202 "Sec Sample Elevated Write"
{
    Assignable = false;
    Caption = 'Elevated write via helper (sample)';
    // Callers hold R directly; the helper codeunit assumes this set and
    // performs the Modify via indirect permission.
    Permissions =
        tabledata "Sales Header" = Rmi;
}

codeunit 50231 "Sec Sample Elevated Helper"
{
    Access = Public;
    Permissions = tabledata "Sales Header" = Rmi;

    procedure SetExternalDocumentNo(SalesDocType: Enum "Sales Document Type"; SalesDocNo: Code[20]; NewExternalDocNo: Code[35])
    var
        SalesHeader: Record "Sales Header";
    begin
        ValidateCaller();
        if NewExternalDocNo = '' then
            Error('External document number must be provided.');
        if not SalesHeader.Get(SalesDocType, SalesDocNo) then
            Error('Sales document not found.');
        SalesHeader."External Document No." := NewExternalDocNo;
        SalesHeader.Modify(true);
    end;

    local procedure ValidateCaller()
    begin
        // Verify the caller is permitted to perform this elevated write
        // (role check, setup flag, approvals, etc.).
    end;
}
