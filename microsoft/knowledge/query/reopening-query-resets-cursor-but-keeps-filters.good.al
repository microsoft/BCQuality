query 50424 "Query Reuse Good"
{
    QueryType = Normal;

    elements
    {
        dataitem(Customer; Customer)
        {
            column(CustomerNo; "No.") { }
        }
    }
}

codeunit 50425 "Query Reuse Good"
{
    procedure ReadTwoIndependentSets(FirstNo: Code[20]; SecondNo: Code[20])
    var
        CustomerQuery: Query "Query Reuse Good";
    begin
        CustomerQuery.SetRange(CustomerNo, FirstNo);
        ReadAll(CustomerQuery);

        Clear(CustomerQuery);
        CustomerQuery.SetRange(CustomerNo, SecondNo);
        ReadAll(CustomerQuery);
    end;

    local procedure ReadAll(var CustomerQuery: Query "Query Reuse Good")
    begin
        CustomerQuery.Open();
        while CustomerQuery.Read() do
            ProcessCustomer(CustomerQuery.CustomerNo);
        CustomerQuery.Close();
    end;

    local procedure ProcessCustomer(CustomerNo: Code[20])
    begin
    end;
}
