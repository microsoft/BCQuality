interface "I Quote Amount Good"
{
    procedure GetAmount(): Decimal;
}

interface "I Quote Date Good"
{
    procedure GetDate(): Date;
}

codeunit 50610 "Quote Reader Good"
{
    procedure TryGetDate(Quote: Interface "I Quote Amount Good"; var QuoteDate: Date): Boolean
    var
        DatedQuote: Interface "I Quote Date Good";
    begin
        if not (Quote is "I Quote Date Good") then
            exit(false);

        DatedQuote := Quote as "I Quote Date Good";
        QuoteDate := DatedQuote.GetDate();
        exit(true);
    end;
}
