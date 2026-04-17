codeunit 50127 "Perf Sample UserInTxn Bad"
{
    procedure ArchiveSalesHeader(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Status := SalesHeader.Status::Released;
        SalesHeader.Modify();
        if not Confirm('Archive document %1?', false, SalesHeader."No.") then
            exit;
        SalesHeader.Delete(true);
    end;
}
