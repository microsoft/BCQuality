// Assign these sets separately to the agent and scheduling user in the task's company.
// Wrong: the agent's Sales Header grant lets the task modify orders even if the user cannot.
// Wrong: the user's Customer grant lets the task modify customers even if the agent cannot.
// Wrong: adding user-administration rights lets the agent manage users.
permissionset 50100 "SALES REVIEW AGENT"
{
    Assignable = true;
    Permissions =
        tabledata "Sales Header" = RIM,
        tabledata Customer = R,
        tabledata User = RIMD,
        tabledata "Access Control" = RIMD,
        table "Sales Header" = X,
        table Customer = X,
        page "Sales Order" = X,
        page "User Card" = X;
}

permissionset 50101 "SALES TASK USER"
{
    Assignable = true;
    Permissions =
        tabledata "Sales Header" = R,
        tabledata Customer = RM,
        table "Sales Header" = X,
        table Customer = X,
        page "Sales Order" = X;
}
