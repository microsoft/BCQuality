table 50100 "Sales Task"
{
    fields
    {
        field(1; "No."; Code[20]) { }
        field(10; Status; Option)
        {
            OptionMembers = Active,Blocked;
        }
    }
}

codeunit 50100 "Sales Task Check"
{
    procedure IsOverdue(DueDate: Date): Integer
    begin
        // 0 = No, 1 = Yes
        if DueDate < Today then
            exit(1);
        exit(0);
    end;
}
