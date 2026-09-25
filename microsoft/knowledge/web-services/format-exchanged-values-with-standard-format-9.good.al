codeunit 50170 "Exchange Rate Export Good"
{
    procedure SendRate(CurrencyCode: Code[10]; StartingDate: Date; ExchangeRate: Decimal)
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        RequestUrl: Text;
    begin
        RequestUrl := StrSubstNo(RateUrlTok, CurrencyCode, Format(StartingDate, 0, 9), Format(ExchangeRate, 0, 9));
        if not Client.Get(RequestUrl, Response) then
            Error(RequestFailedErr);
        if not Response.IsSuccessStatusCode() then
            Error(RateRejectedErr, Response.HttpStatusCode());
    end;

    procedure ReadRate(RateText: Text) ExchangeRate: Decimal
    begin
        if not Evaluate(ExchangeRate, RateText, 9) then
            Error(InvalidRateErr, RateText);
    end;

    var
        RateUrlTok: Label 'https://rates.example.com/rates?currency=%1&date=%2&rate=%3', Locked = true;
        RequestFailedErr: Label 'The exchange rate service could not be reached.';
        RateRejectedErr: Label 'The exchange rate service rejected the rate. Status code: %1.', Comment = '%1 = HTTP status code';
        InvalidRateErr: Label 'The exchange rate %1 is not a valid decimal number.', Comment = '%1 = received value';
}
