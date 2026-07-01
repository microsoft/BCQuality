codeunit 50132 "LoadFields Good Sample"
{
    procedure TotalReleasedAmount(): Decimal
    var
        SalesHeader: Record "Sales Header";
        Total: Decimal;
    begin
        // Every field read in the loop is listed, so each row stays a cheap
        // partial load with no hidden second round-trip.
        SalesHeader.SetLoadFields("Amount Including VAT", Status);
        if SalesHeader.FindSet() then
            repeat
                if SalesHeader.Status = SalesHeader.Status::Released then
                    Total += SalesHeader."Amount Including VAT";
            until SalesHeader.Next() = 0;
        exit(Total);
    end;
}
