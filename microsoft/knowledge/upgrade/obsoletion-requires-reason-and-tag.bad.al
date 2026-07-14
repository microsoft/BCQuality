codeunit 50228 "Old Method Holder"
{
    // Methods use the attribute, but empty reason and tag give no migration path.
    [Obsolete('', '')]
    procedure OldMethod()
    begin
    end;
}
