codeunit 50100 "Tax Posting Helper"
{
    procedure GetTaxAccount(var Setup: Record "Sales & Receivables Setup"): Code[20]
    begin
        Setup.Get();
        Setup.TestField("Tax Account No.");
        exit(Setup."Tax Account No.");
    end;
}
