codeunit 50129 "Perf Sample CommitInLoop Bad"
{
    procedure ReleaseAllOrders()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange(Status, SalesHeader.Status::Open);
        if SalesHeader.FindSet() then
            repeat
                SalesHeader.Status := SalesHeader.Status::Released;
                SalesHeader.Modify();
                Commit();
            until SalesHeader.Next() = 0;
    end;
}
