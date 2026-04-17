codeunit 50126 "Perf Sample UserInTxn Good"
{
    procedure ArchiveSalesHeader(var SalesHeader: Record "Sales Header")
    begin
        if not Confirm('Archive document %1?', false, SalesHeader."No.") then
            exit;
        DoArchive(SalesHeader);
    end;

    local procedure DoArchive(var SalesHeader: Record "Sales Header")
    begin
        // only Insert/Modify/Delete calls happen here; no prompts
    end;
}
