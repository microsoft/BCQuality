interface "Sec Sample Transport Good"
{
    // The seam is Text by design: the test double asserts WHERE the credential travels.
    procedure Send(Uri: Text; AuthorizationHeader: Text): Boolean;
}

codeunit 50540 "Sec Sample Text Seam Good"
{
    var
        Transport: Interface "Sec Sample Transport Good";

    [NonDebuggable]
    procedure Call(Uri: Text; ServiceCode: Code[20]): Boolean
    var
        ApiKey: Text;
    begin
        // Plain-text path kept as short as possible; value is encrypted at rest.
#pragma warning disable LC0043 // Text seam: the transport interface and its test double are typed Text on purpose
        if not IsolatedStorage.Get(ServiceCode, DataScope::Company, ApiKey) then
            exit(false);
        exit(Transport.Send(Uri, 'Bearer ' + ApiKey));
#pragma warning restore LC0043
    end;

    [NonDebuggable]
    procedure Store(ServiceCode: Code[20]; ApiKey: Text)
    begin
        IsolatedStorage.SetEncrypted(ServiceCode, ApiKey, DataScope::Company);
    end;
}
