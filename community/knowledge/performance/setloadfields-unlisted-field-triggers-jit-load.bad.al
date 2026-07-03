codeunit 50132 "LoadFields Bad Sample"
{
    procedure TotalReleasedAmount(): Decimal
    var
        SalesHeader: Record "Sales Header";
        Total: Decimal;
    begin
        // "Currency Code" is not listed. The helper takes SalesHeader BY VALUE,
        // so the copy neither shares the load set nor updates the enumerator:
        // reading the unlisted field triggers a fresh JIT load (an extra Get)
        // on EVERY iteration, quietly reversing the saving.
        SalesHeader.SetLoadFields("Amount Including VAT", Status);
        if SalesHeader.FindSet() then
            repeat
                if IsLocalReleased(SalesHeader) then
                    Total += SalesHeader."Amount Including VAT";
            until SalesHeader.Next() = 0;
        exit(Total);
    end;

    local procedure IsLocalReleased(SalesHeader: Record "Sales Header"): Boolean
    begin
        exit((SalesHeader.Status = SalesHeader.Status::Released) and
             (SalesHeader."Currency Code" = ''));
    end;
}
