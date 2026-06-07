// Anti-pattern: the failure path records only a raw error string and a Failed
// status. There is no error class, so every failure looks the same. On a busy
// Monday an operator must open and read three hundred rows to learn that most
// were timeouts that would have healed on their own, a handful were bad
// addresses, and one was a renamed field that should have paged an engineer.

codeunit 50140 "Handle Integration Failure"
{
    procedure OnFailure(var IntegrationMessage: Record "Integration Message"; ErrorText: Text)
    begin
        IntegrationMessage.Status := IntegrationMessage.Status::Failed;
        // BAD: raw text, no classification. Nothing tells ops whether to fix
        // data, wait for the retry, or escalate. The resolution page shows one
        // undifferentiated Failed bucket and time-to-resolve grows with the queue.
        IntegrationMessage."Error Message" := CopyStr(ErrorText, 1, MaxStrLen(IntegrationMessage."Error Message"));
        IntegrationMessage.Modify(true);

        // BAD: a blanket retry of every Failed row, because the code cannot tell
        // transient from permanent. Data errors and contract breaks are retried
        // forever, hammering the remote and never reaching a human.
    end;
}
