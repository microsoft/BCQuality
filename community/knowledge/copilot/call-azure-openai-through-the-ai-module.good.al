// Demonstration only. Shows the recommended pattern: the call goes through the System.AI module for a registered capability.

codeunit 50207 "Item Desc Generator Good"
{
    Access = Internal;

    procedure Generate(ItemNo: Code[20]; Endpoint: Text; Deployment: Text; ApiKey: SecretText): Text
    var
        Item: Record Item;
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        NotAvailableErr: Label 'Drafting item descriptions with Copilot is not available. Ask your administrator to activate it on the Copilot & agent capabilities page.';
        GenerationFailedErr: Label 'Copilot could not draft a description. Try again later.';
    begin
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Draft Item Description", true) then
            Error(NotAvailableErr);

        Item.Get(ItemNo);
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", Endpoint, Deployment, ApiKey);
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Draft Item Description");
        AOAIChatCompletionParams.SetTemperature(0);

        AOAIChatMessages.SetPrimarySystemMessage('You write short, factual product descriptions for an item catalog.');
        AOAIChatMessages.AddUserMessage(Item.Description);
        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);
        if not AOAIOperationResponse.IsSuccess() then
            Error(GenerationFailedErr);
        exit(AOAIChatMessages.GetLastMessage());
    end;
}

enumextension 50207 "Item Draft Capability" extends "Copilot Capability"
{
    value(50207; "Draft Item Description")
    {
        Caption = 'Draft item description';
    }
}
