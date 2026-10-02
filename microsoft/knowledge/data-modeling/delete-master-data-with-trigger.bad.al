codeunit 50100 "Sample Currency Cleanup"
{
    procedure DeleteRetiredCurrencies(CurrencyFilter: Text)
    var
        Currency: Record Currency;
    begin
        Currency.SetFilter(Code, CurrencyFilter);
        // RunTrigger defaults to false: Currency.OnDelete never runs, so the
        // open-entry guard is skipped and exchange rates are left orphaned.
        Currency.DeleteAll();
    end;
}
