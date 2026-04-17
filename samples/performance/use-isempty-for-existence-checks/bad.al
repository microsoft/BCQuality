codeunit 50121 "Perf Sample IsEmpty Bad"
{
    procedure HasOpenDocuments(CustomerNo: Code[20]): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        SalesHeader.SetRange(Status, SalesHeader.Status::Open);
        exit(SalesHeader.Count() > 0);
    end;
}
