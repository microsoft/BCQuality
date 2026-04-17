codeunit 50205 "Sec Sample Inherent Bad"
{
    // No InherentPermissions attribute: every caller must hold
    // tabledata "Sec Sample Lookup" = R just to look up a name.
    procedure GetLookupName(LookupCode: Code[20]): Text[100]
    var
        Lookup: Record "Sec Sample Lookup";
    begin
        if Lookup.Get(LookupCode) then
            exit(Lookup.Name);
        exit('');
    end;
}
