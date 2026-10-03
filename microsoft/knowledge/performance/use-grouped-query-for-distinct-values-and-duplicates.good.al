// One row per customer name that occurs more than once.
// Name is a plain column, so it is the grouping key; the ColumnFilter on the
// Count column is applied after grouping (HAVING COUNT(*) > 1).
query 50570 "Duplicate Customer Names"
{
    QueryType = Normal;

    elements
    {
        dataitem(Customer; Customer)
        {
            column(Name; Name)
            {
                ColumnFilter = Name = filter(<> '');
            }
            column(NameCount)
            {
                Method = Count;
                ColumnFilter = NameCount = filter(> 1);
            }
        }
    }
}

codeunit 50571 "Customer Name Review"
{
    procedure HasDuplicateCustomerNames(): Boolean
    var
        DuplicateCustomerNames: Query "Duplicate Customer Names";
        Found: Boolean;
    begin
        DuplicateCustomerNames.Open();
        Found := DuplicateCustomerNames.Read();
        DuplicateCustomerNames.Close();
        exit(Found);
    end;

    procedure GetDuplicateCustomerNames(var DuplicateNames: List of [Text])
    var
        DuplicateCustomerNames: Query "Duplicate Customer Names";
    begin
        DuplicateCustomerNames.Open();
        while DuplicateCustomerNames.Read() do
            DuplicateNames.Add(DuplicateCustomerNames.Name);
        DuplicateCustomerNames.Close();
    end;
}
