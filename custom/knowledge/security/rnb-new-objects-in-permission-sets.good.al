codeunit 50100 "RNB Reference Processor"
{
    procedure RefreshReference()
    begin
    end;
}

permissionset 50100 "RNB Reference User"
{
    Assignable = true;

    Permissions =
        codeunit "RNB Reference Processor" = X;
}