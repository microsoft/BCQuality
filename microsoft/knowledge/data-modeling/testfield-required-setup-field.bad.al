codeunit 50100 "Tax Posting Helper"
{
    procedure GetTaxAccount(var Setup: Record "Sales & Receivables Setup"): Code[20]
    var
        DefaultTaxAccountTxt: Label 'DEFAULT-TAX';
    begin
        Setup.Get();
        if Setup."Tax Account No." <> '' then
            exit(Setup."Tax Account No.");
        exit(DefaultTaxAccountTxt);
    end;
}
