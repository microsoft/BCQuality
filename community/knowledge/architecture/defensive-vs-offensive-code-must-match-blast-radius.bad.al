codeunit 50150 "Contoso Header Field Lookup"
{
    procedure GetVatProdPostingGroup(DocumentNo: Code[20]): Code[20]
    var
        Header: Record "Contoso Document Header";
    begin
        // The same guarded shape used for a low-risk field is reused here
        // without re-examining the consequence — a missing header now
        // silently posts with a blank VAT posting group.
        if Header.Get(DocumentNo) then
            exit(Header."VAT Prod. Posting Group");
        exit('');
    end;
}
