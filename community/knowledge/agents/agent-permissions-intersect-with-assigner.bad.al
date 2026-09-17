permissionset 50100 "SALES REVIEW AGENT"
{
    Assignable = true;
    Permissions =
        tabledata "Sales Header" = RIM,
        tabledata Customer = R,
        tabledata User = RIMD,
        tabledata "Access Control" = RIMD,
        page "Sales Order" = X,
        page "User Card" = X;
}
