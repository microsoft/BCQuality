query 50100 "Query Bypass PK Cache Bad Q"
{
    QueryType = Normal;

    elements
    {
        dataitem(Customer; Customer)
        {
            filter(NoFilter; "No.") { }
            column(Name; Name) { }
        }
    }
}

codeunit 50100 "Query Bypass PK Cache Bad"
{
    procedure CustomerName(CustomerNo: Code[20]): Text
    var
        CustomerByNo: Query "Query Bypass PK Cache Bad Q";
    begin
        // Query Open/Read never hits the server PK cache.
        CustomerByNo.SetRange(NoFilter, CustomerNo);
        CustomerByNo.Open();
        if CustomerByNo.Read() then
            exit(CustomerByNo.Name);
        CustomerByNo.Close();
    end;
}
