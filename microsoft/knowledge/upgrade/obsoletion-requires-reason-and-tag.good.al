codeunit 50227 "Old Method Holder"
{
    [Obsolete('Use NewMethod instead for better performance', '22.0')]
    procedure OldMethod()
    begin
        // The method remains callable during its deprecation window.
    end;

    procedure NewMethod()
    begin
    end;
}
