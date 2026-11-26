codeunit 50830 "Sample Feature Gate"
{
    procedure CheckFeatureAvailable(FeatureEnabled: Boolean)
    begin
        if not FeatureEnabled then
            Error(FeatureRequiresProductErr);
    end;

    procedure ShowWelcomeMessage()
    begin
        Message(WelcomeMsg);
    end;

    var
        FeatureRequiresProductErr: Label 'This feature requires Dynamics 365 Business Central.';
        WelcomeMsg: Label 'Welcome to Business Central.';
}
