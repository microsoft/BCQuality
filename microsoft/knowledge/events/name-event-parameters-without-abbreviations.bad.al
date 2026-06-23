// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50276 "Param Naming Bad Sample"
{
    procedure RegisterPayment(var SalesHdr: Record "Sales Header"; DocNo: Code[20]; Amt: Decimal)
    begin
        // Anti-pattern: abbreviated parameter names force every subscriber to
        // guess what SalesHdr, DocNo and Amt mean.
        OnAfterRegisterPayment(SalesHdr, DocNo, Amt);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRegisterPayment(var SalesHdr: Record "Sales Header"; DocNo: Code[20]; Amt: Decimal)
    begin
    end;
}
