codeunit 50138 "Perf Sample SingleInstance Good"
{
    SingleInstance = true;

    var
        Cached: Record "Sales & Receivables Setup";
        Loaded: Boolean;

    procedure GetSetup(): Record "Sales & Receivables Setup"
    begin
        if not Loaded then begin
            Cached.Get();
            Loaded := true;
        end;
        exit(Cached);
    end;
}
