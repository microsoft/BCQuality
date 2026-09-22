table 50100 "Sales Task"
{
    fields
    {
        field(1; "No."; Code[20]) { }
        field(10; Blocked; Boolean) { }
    }
}

codeunit 50100 "Sales Task Check"
{
    procedure IsOverdue(DueDate: Date): Boolean
    begin
        exit(DueDate < Today);
    end;
}
