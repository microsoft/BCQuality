codeunit 50120 "Perf Sample IsEmpty Good"
{
    procedure HasOpenDocuments(CustomerNo: Code[20]): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        SalesHeader.SetRange(Status, SalesHeader.Status::Open);
        exit(not SalesHeader.IsEmpty());
    end;
}
