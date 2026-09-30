// Demonstration only; independently authored, not copied from BaseApp.
codeunit 50108 "Import Purchase Journal Total"
{
    procedure ImportExampleTotal(TemplateName: Code[10]; BatchName: Code[10]; LineNo: Integer)
    var
        JournalLine: Record "Gen. Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        SourceInvoice: JsonObject;
        NetToken: JsonToken;
        VATToken: JsonToken;
        GrossToken: JsonToken;
        ImportedNet: Decimal;
        ImportedVAT: Decimal;
        ImportedGross: Decimal;
    begin
        SourceInvoice.ReadFrom('{"netAmount":100,"vatAmount":25,"grossAmount":125}');
        SourceInvoice.Get('netAmount', NetToken);
        SourceInvoice.Get('vatAmount', VATToken);
        SourceInvoice.Get('grossAmount', GrossToken);
        ImportedNet := NetToken.AsValue().AsDecimal();
        ImportedVAT := VATToken.AsValue().AsDecimal();
        ImportedGross := GrossToken.AsValue().AsDecimal();
        if ImportedGross <> ImportedNet + ImportedVAT then
            Error(TotalsErr);

        JournalLine.Get(TemplateName, BatchName, LineNo);
        JournalLine.TestField("Account Type", JournalLine."Account Type"::"G/L Account");
        JournalLine.TestField("Bal. Account Type", JournalLine."Bal. Account Type"::"G/L Account");
        JournalLine.TestField("Account No.");
        JournalLine.TestField("Bal. Account No.");
        JournalLine.TestField("Currency Code", '');
        JournalLine.TestField("Gen. Posting Type", JournalLine."Gen. Posting Type"::Purchase);
        JournalLine.TestField("VAT Posting", JournalLine."VAT Posting"::"Automatic VAT Entry");
        JournalLine.TestField("VAT Calculation Type", JournalLine."VAT Calculation Type"::"Normal VAT");
        JournalLine.TestField("VAT %", 25);
        JournalLine.TestField("VAT Difference", 0);
        JournalLine.TestField("Bal. Gen. Posting Type", JournalLine."Bal. Gen. Posting Type"::" ");
        JournalLine.TestField("Bal. VAT %", 0);
        VATPostingSetup.Get(JournalLine."VAT Bus. Posting Group", JournalLine."VAT Prod. Posting Group");
        VATPostingSetup.TestField("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        VATPostingSetup.TestField("VAT %", 25);
        VATPostingSetup.TestField("Unrealized VAT Type", VATPostingSetup."Unrealized VAT Type"::" ");
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.TestField("Additional Reporting Currency", '');
        GeneralLedgerSetup.TestField("Amount Rounding Precision", 0.01);

        JournalLine.Validate(Amount, ImportedGross);
        JournalLine.Modify(true);
    end;

    var
        TotalsErr: Label 'The invoice total must equal its net amount plus VAT.';
}
