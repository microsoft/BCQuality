permissionset 50100 "SALES REVIEW AGENT"
{
    Assignable = true;
    Permissions =
        tabledata "Sales Header" = RIM,
        tabledata Customer = R,
        page "Sales Order" = X;
}
