codeunit 50321 "Payment Client Bad"
{
    Access = Public;

    [NonDebuggable]
    procedure GetAccessToken(): SecretText
    var
        AccessToken: SecretText;
    begin
        IsolatedStorage.Get('PaymentServiceToken', DataScope::Module, AccessToken);
        exit(AccessToken);
    end;
}
