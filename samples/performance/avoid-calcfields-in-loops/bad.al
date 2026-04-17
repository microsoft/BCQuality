codeunit 50117 "Perf Sample CalcFieldsInLoop Bad"
{
    procedure ProcessLargeLines(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                SalesHeader.CalcFields(Amount);
                if SalesHeader.Amount > 1000 then
                    ProcessLine(SalesLine);
            until SalesLine.Next() = 0;
    end;

    local procedure ProcessLine(var SalesLine: Record "Sales Line")
    begin
    end;
}
