codeunit 50211 "Privacy Sample LogMessage Bad"
{
    procedure LogCompleted()
    begin
        Session.LogMessage('PRIV0004', 'Operation completed', Verbosity::Normal);
    end;
}
