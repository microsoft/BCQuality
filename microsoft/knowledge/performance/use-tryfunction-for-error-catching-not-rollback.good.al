codeunit 50155 "Perf Sample TryFunc Good"
{
    procedure ParseAndProcess(Payload: Text)
    var
        ParsedValue: Decimal;
    begin
        ClearLastError();
        if not TryParseDecimal(Payload, ParsedValue) then begin
            LogParseFailure(Payload, GetLastErrorText());
            exit;
        end;
    end;

    [TryFunction]
    local procedure TryParseDecimal(Input: Text; var Result: Decimal)
    begin
        Evaluate(Result, Input);
    end;

    local procedure LogParseFailure(Payload: Text; Reason: Text)
    begin
    end;
}
