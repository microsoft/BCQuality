codeunit 50224 "Sec Sample ErrorDisclosure Good"
{
    var
        ConnectionFailedErr: Label 'Connection to the external service failed. Contact your administrator.';

    procedure Connect()
    begin
        if not TryConnect() then begin
            LogConnectionFailure(GetLastErrorText());
            Error(ConnectionFailedErr);
        end;
    end;

    [TryFunction]
    local procedure TryConnect()
    begin
        // ...
    end;

    local procedure LogConnectionFailure(Detail: Text)
    begin
        // Route to controlled logging (Session.LogMessage, activity log, etc.).
    end;
}
