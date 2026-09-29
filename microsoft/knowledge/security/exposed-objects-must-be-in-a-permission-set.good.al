permissionset 50100 "Sample - Integration"
{
    Access = Public;
    Assignable = false;
    Caption = 'Sample Integration';
    Permissions =
        tabledata "Sample Order" = RIMD,
        page "Sample Order API" = X,      // exposed API page: execute granted
        query "Sample Order Query" = X;   // exposed API query: execute granted
}
