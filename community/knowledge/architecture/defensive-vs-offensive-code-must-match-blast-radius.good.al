codeunit 50150 "Contoso Header Field Lookup"
{
    procedure GetVatRegNo(DocumentNo: Code[20]): Text[20]
    var
        Header: Record "Contoso Document Header";
    begin
        // Low blast radius: informational field, safe to default if missing.
        if Header.Get(DocumentNo) then
            exit(Header."VAT Registration No.");
        exit('');
    end;

    procedure GetVatProdPostingGroup(DocumentNo: Code[20]): Code[20]
    var
        Header: Record "Contoso Document Header";
    begin
        // High blast radius: feeds a posted VAT calculation. Fail loud.
        Header.Get(DocumentNo);
        Header.TestField("VAT Prod. Posting Group");
        exit(Header."VAT Prod. Posting Group");
    end;
}
