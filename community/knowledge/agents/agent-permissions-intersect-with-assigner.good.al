// Assign these sets separately to the agent and scheduling user in the task's company.
// Assume no additional grants. Effective tabledata rights are R on both tables:
// the user lacks Sales Header modification, and the agent lacks Customer modification.
permissionset 50100 "SALES REVIEW AGENT"
{
    Assignable = true;
    Permissions =
        tabledata "Sales Header" = RIM,
        tabledata Customer = R,
        table "Sales Header" = X,
        table Customer = X,
        page "Sales Order" = X;
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
