codeunit 50320 "Payment Client Good"
{
    var
        AccessToken: SecretText;

    // Credential remains SecretText as it flows inward and is stored.
    internal procedure SetAccessToken(NewToken: SecretText)
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
