// Demonstration only. Shows the recommended pattern: the operation response is checked before the output is used.

codeunit 50209 "Email Draft Generator Good"
{
    Access = Internal;

    var
        GenerationFailedErr: Label 'Copilot could not draft the reminder right now. Try again in a moment.';

    procedure DraftReminder(var ReminderDraft: Record "Reminder Draft Demo"; CustomerName: Text; Endpoint: Text; Deployment: Text; ApiKey: SecretText)
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
    begin
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", Endpoint, Deployment, ApiKey);
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Draft Payment Reminder");
        AOAIChatMessages.SetPrimarySystemMessage('Write a polite payment reminder email.');
        AOAIChatMessages.AddUserMessage(CustomerName);
        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIOperationResponse);

        if not AOAIOperationResponse.IsSuccess() then
            Error(GenerationFailedErr);

        ReminderDraft."Body Text" := CopyStr(AOAIChatMessages.GetLastMessage(), 1, MaxStrLen(ReminderDraft."Body Text"));
        ReminderDraft.Modify(true);
    end;
}

table 50209 "Reminder Draft Demo"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20]) { }
        field(2; "Body Text"; Text[2048]) { }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
    }
}

enumextension 50209 "Reminder Draft Capability" extends "Copilot Capability"
{
    value(50209; "Draft Payment Reminder")
    {
        Caption = 'Draft payment reminder';
    }
}
