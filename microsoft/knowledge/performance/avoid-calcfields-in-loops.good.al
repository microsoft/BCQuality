codeunit 50116 "Perf Sample CalcFieldsInLoop Good"
{
    procedure ProcessLargeLines(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        SalesHeader.CalcFields(Amount);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                if SalesHeader.Amount > 1000 then
                    ProcessLine(SalesLine);
            until SalesLine.Next() = 0;
    end;

    local procedure ProcessLine(var SalesLine: Record "Sales Line")
    begin
    end;
}
