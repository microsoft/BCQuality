interface "Sec Sample Transport Bad"
{
    procedure Send(Uri: Text; AuthorizationHeader: Text): Boolean;
}

codeunit 50541 "Sec Sample Text Seam Bad"
{
    var
        Transport: Interface "Sec Sample Transport Bad";

    // Half conversion: the parameter became SecretText to satisfy the analyzer,
    // but the seam is still Text, so the value is unwrapped right away.
    // Unwrap is on-premises only: this does not hold for a cloud-targeted app.
    procedure Call(Uri: Text; ApiKey: SecretText): Boolean
    begin
        exit(Transport.Send(Uri, 'Bearer ' + ApiKey.Unwrap()));
    end;
}
