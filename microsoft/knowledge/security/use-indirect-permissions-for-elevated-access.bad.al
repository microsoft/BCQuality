permissionset 50203 "Sec Sample Direct Write"
{
    Assignable = true;
    Caption = 'Direct write granted to every caller (sample anti-pattern)';
    Permissions =
        tabledata "Sales Header" = RM;
}
