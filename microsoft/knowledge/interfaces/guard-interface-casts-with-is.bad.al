interface "I Quote Amount Bad"
{
    procedure GetAmount(): Decimal;
}

interface "I Quote Date Bad"
{
    procedure GetDate(): Date;
}

codeunit 50611 "Quote Reader Bad"
{
    procedure GetDate(Quote: Interface "I Quote Amount Bad"): Date
    var
        DatedQuote: Interface "I Quote Date Bad";
    begin
        DatedQuote := Quote as "I Quote Date Bad";
        exit(DatedQuote.GetDate());
    end;
}
