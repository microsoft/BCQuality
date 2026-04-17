table 50230 "Sec Sample Lookup"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Code"; Code[20]) { }
        field(2; "Name"; Text[100]) { }
    }

    keys
    {
        key(PK; "Code") { Clustered = true; }
    }
}

codeunit 50204 "Sec Sample Inherent Good"
{
    [InherentPermissions(PermissionObjectType::TableData, Database::"Sec Sample Lookup", 'r')]
    procedure GetLookupName(LookupCode: Code[20]): Text[100]
    var
        Lookup: Record "Sec Sample Lookup";
    begin
        if Lookup.Get(LookupCode) then
            exit(Lookup.Name);
        exit('');
    end;
}
