permissionset 50203 "Sec Sample Report Runner"
{
    Permissions = tabledata "G/L Entry" = r,
                  codeunit "Sec Ledger Reader" = X;
}

codeunit 50205 "Sec Ledger Reader"
{
    Permissions = tabledata "G/L Entry" = r;

    procedure GetEntryCount(): Integer
    var
        GLEntry: Record "G/L Entry";
    begin
        exit(GLEntry.Count());
    end;
}
