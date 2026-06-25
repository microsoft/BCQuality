// Building blocks: focused per-concern, marked Assignable = false so administrators
// do not accidentally assign a fragment.
permissionset 50100 "Sales Tables - Read"
{
    Assignable = false;
    Permissions =
        tabledata Customer = R,
        tabledata "Sales Header" = R,
        tabledata "Sales Line" = R;
}

permissionset 50101 "Sales Tables - Edit"
{
    Assignable = false;
    IncludedPermissionSets = "Sales Tables - Read";
    Permissions =
        tabledata Customer = IM,
        tabledata "Sales Header" = IMD,
        tabledata "Sales Line" = IMD;
}

// Role-shaped, Assignable = true, composed from building blocks.
// Adding a new Sales table means editing one building block; both roles inherit the change.
permissionset 50110 "Sales Order Processor"
{
    Assignable = true;
    IncludedPermissionSets = "Sales Tables - Edit";
}

permissionset 50111 "Sales Viewer"
{
    Assignable = true;
    IncludedPermissionSets = "Sales Tables - Read";
}
