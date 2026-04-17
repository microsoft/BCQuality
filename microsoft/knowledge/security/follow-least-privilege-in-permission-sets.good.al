permissionset 50200 "Sec Sample Sales Order Entry"
{
    Assignable = true;
    Caption = 'Sales Order Entry (sample)';
    Permissions =
        tabledata "Sales Header" = RIM,
        tabledata "Sales Line" = RIMD,
        tabledata Customer = R;
}
