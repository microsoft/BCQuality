codeunit 50818 "Upgrade Sample Obsolete Bad"
{
    // Straight to Removed with no preceding Pending phase, no ObsoleteReason,
    // no ObsoleteTag. Dependents compiled against the previous release hit
    // a hard compile error with no migration signal.
    [Obsolete('', '')]
    procedure CalculateNetAmount(Amount: Decimal): Decimal
    begin
        Error('Removed.');
    end;
}
