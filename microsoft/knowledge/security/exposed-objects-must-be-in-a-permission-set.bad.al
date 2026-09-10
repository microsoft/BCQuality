permissionset 50100 "Sample - Integration"
{
    Access = Public;
    Assignable = false;
    Caption = 'Sample Integration';
    Permissions =
        tabledata "Sample Order" = RIMD;
        // BUG: "Sample Order API" (PageType = API) and "Sample Order Query"
        // (a published API query) have no "= X" entry anywhere in this app.
        // Both endpoints are unreachable even though the table looks fully
        // granted - nobody decided who may call them.
}
