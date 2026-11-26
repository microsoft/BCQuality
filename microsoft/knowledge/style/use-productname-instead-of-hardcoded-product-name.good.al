codeunit 50830 "Sample Feature Gate"
{
    procedure CheckFeatureAvailable(FeatureEnabled: Boolean)
    begin
        if not FeatureEnabled then
            Error(FeatureRequiresProductErr, ProductName.Full());
    end;

    procedure ShowWelcomeMessage()
    begin
        Message(WelcomeMsg, ProductName.Short());
    end;

    var
        FeatureRequiresProductErr: Label 'This feature requires %1.', Comment = '%1 = the full product name, for example Dynamics 365 Business Central';
        WelcomeMsg: Label 'Welcome to %1.', Comment = '%1 = the short product name, for example Business Central';
}
