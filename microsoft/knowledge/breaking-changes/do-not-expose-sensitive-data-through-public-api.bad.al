codeunit 50321 "Payment Client Bad"
{
    var
        AccessToken: Text;

    // Crossing the trust boundary: a public getter hands the raw credential to any
    // caller, turning a secret into a de-facto public API that cannot be removed
    // later without breaking consumers.
    procedure GetAccessToken(): Text
    begin
        exit(AccessToken);
    end;
}
