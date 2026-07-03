codeunit 50132 "LoadFields Good Sample"
{
    procedure TotalReleasedAmount(): Decimal
    var
        SalesHeader: Record "Sales Header";
        Total: Decimal;
    begin
        // Every field read anywhere downstream is listed — including the one
        // the by-var helper reads — so no JIT load is ever triggered.
        SalesHeader.SetLoadFields("Amount Including VAT", Status, "Currency Code");
        if SalesHeader.FindSet() then
            repeat
                if IsLocalReleased(SalesHeader) then
                    Total += SalesHeader."Amount Including VAT";
            until SalesHeader.Next() = 0;
        exit(Total);
    end;

    local procedure IsLocalReleased(var SalesHeader: Record "Sales Header"): Boolean
    begin
        exit((SalesHeader.Status = SalesHeader.Status::Released) and
             (SalesHeader."Currency Code" = ''));
    end;
}
