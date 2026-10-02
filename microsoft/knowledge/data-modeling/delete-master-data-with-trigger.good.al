codeunit 50100 "Sample Currency Cleanup"
{
    procedure DeleteRetiredCurrencies(CurrencyFilter: Text)
    var
        Currency: Record Currency;
    begin
        Currency.SetFilter(Code, CurrencyFilter);
        // DeleteAll(true) runs Currency.OnDelete for each record: it errors while
        // open ledger entries use the code and removes the exchange rates itself.
        Currency.DeleteAll(true);
    end;
}
