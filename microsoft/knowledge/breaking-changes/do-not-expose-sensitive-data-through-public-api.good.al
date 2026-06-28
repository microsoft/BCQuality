codeunit 50320 "Payment Client Good"
{
    var
        AccessToken: Text;

    // Credential flows inward through an internal setter and never leaves the object.
    internal procedure SetAccessToken(NewToken: Text)
    begin
        AccessToken := NewToken;
    end;

    // Public API exposes only non-sensitive data — a masked reference, never the token.
    procedure GetMaskedReference(): Text
    var
        Reference: Text;
    begin
        Reference := LastReference();
        exit('****-' + CopyStr(Reference, StrLen(Reference) - 3));
    end;

    local procedure LastReference(): Text
    begin
        exit('REF000123456');
    end;
}
