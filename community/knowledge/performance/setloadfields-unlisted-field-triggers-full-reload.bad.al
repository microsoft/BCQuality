codeunit 50132 "LoadFields Bad Sample"
{
    procedure TotalReleasedAmount(): Decimal
    var
        SalesHeader: Record "Sales Header";
        Total: Decimal;
    begin
        // "Currency Code" is not in the list. Reading it each iteration forces
        // a second database round-trip that reloads the WHOLE row — N full
        // reloads, slower than never calling SetLoadFields at all.
        SalesHeader.SetLoadFields("Amount Including VAT", Status);
        if SalesHeader.FindSet() then
            repeat
                if (SalesHeader.Status = SalesHeader.Status::Released) and
                   (SalesHeader."Currency Code" = '') then
                    Total += SalesHeader."Amount Including VAT";
            until SalesHeader.Next() = 0;
        exit(Total);
    end;
}
