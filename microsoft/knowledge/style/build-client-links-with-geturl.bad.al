codeunit 50620 "Sales Order Link"
{
    procedure GetSalesOrderLink(SalesHeader: Record "Sales Header"): Text
    begin
        exit('https://businesscentral.dynamics.com/' + TenantDomainTxt + '/Production/?company=' + CompanyName() +
          '&page=' + Format(Page::"Sales Order") + '&filter=''No.'' IS ''' + SalesHeader."No." + '''');
    end;

    var
        TenantDomainTxt: Label 'contoso.onmicrosoft.com', Locked = true;
}
