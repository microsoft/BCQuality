// Two role-shaped sets, each re-enumerating the same objects. Adding a new
// Sales table means editing both sets by hand; forgetting one creates a
// subtle authorization bug where one role was updated and its sibling was not.

permissionset 50110 "Sales Order Processor"
{
    Assignable = true;
    Permissions =
        tabledata Customer = IM,
        tabledata "Sales Header" = IMD,
        tabledata "Sales Line" = IMD;
}

permissionset 50111 "Sales Viewer"
{
    Assignable = true;
    Permissions =
        tabledata Customer = R,
        tabledata "Sales Header" = R,
        tabledata "Sales Line" = R;
}
