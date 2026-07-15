query 50426 "Query Reuse Bad"
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

codeunit 50427 "Query Reuse Bad"
{
    procedure ReadAgain(CustomerNoFilter: Code[20])
    var
        CustomerQuery: Query "Query Reuse Bad";
    begin
        CustomerQuery.SetRange(CustomerNo, CustomerNoFilter);
        CustomerQuery.Open();
        if CustomerQuery.Read() then;

        // Reopening resets to the first row and retains CustomerNo.
        CustomerQuery.Open();
        if CustomerQuery.Read() then;
    end;
}
