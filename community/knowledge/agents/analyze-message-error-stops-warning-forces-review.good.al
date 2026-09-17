codeunit 50100 "Sales Review Agent Task"
{
    procedure AnalyzeAgentTaskMessage(AgentTaskMessage: Record "Agent Task Message"; var Annotations: Record "Agent Annotation")
    var
        AgentMessage: Codeunit "Agent Message";
        EmptyMessageMsg: Label 'Message is empty.';
        EmptyMessageDetailsTxt: Label 'Provide a sales order task before running the agent.';
        NotRelevantMsg: Label 'Message is not a sales order task.';
        NotRelevantDetailsTxt: Label 'Provide a message related to sales order review.';
        MessageText: Text;
    begin
        if AgentTaskMessage.Type = AgentTaskMessage.Type::Output then begin
            AgentMessage.UpdateText(AgentTaskMessage, AgentMessage.GetText(AgentTaskMessage) + #13#10 + #13#10 + 'Written with the help of AI');
            exit;
        end;

        MessageText := AgentMessage.GetText(AgentTaskMessage);
        if MessageText = '' then begin
            Clear(Annotations);
            Annotations.Code := 'MESSAGE001';
            Annotations.Severity := Annotations.Severity::Error;
            Annotations.Message := EmptyMessageMsg;
            Annotations.Details := EmptyMessageDetailsTxt;
            Annotations.Insert();
            exit;
        end;
        if not IsRelevant(MessageText) then begin
            Clear(Annotations);
            Annotations.Code := 'RELEVANCE001';
            Annotations.Severity := Annotations.Severity::Warning;
            Annotations.Message := NotRelevantMsg;
            Annotations.Details := NotRelevantDetailsTxt;
            Annotations.Insert();
        end;
    end;

    local procedure IsRelevant(MessageText: Text): Boolean
    begin
        exit(StrPos(LowerCase(MessageText), 'sales order') > 0);
    end;
}
