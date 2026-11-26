// Demonstration only. Shows the wrong pattern: a Copilot feature that posts directly to the Azure OpenAI REST endpoint.

codeunit 50206 "Item Desc Generator Bad"
{
    Access = Internal;

    procedure Generate(ItemNo: Code[20]; ApiKey: SecretText): Text
    var
        Item: Record Item;
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        Response: HttpResponseMessage;
        Body: JsonObject;
        Messages: JsonArray;
        UserMessage: JsonObject;
        RequestText: Text;
        ResponseText: Text;
    begin
        Item.Get(ItemNo);
        UserMessage.Add('role', 'user');
        UserMessage.Add('content', 'Write a product description for ' + Item.Description);
        Messages.Add(UserMessage);
        Body.Add('messages', Messages);
        Body.WriteTo(RequestText);

        Content.WriteFrom(RequestText);
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');
        Client.DefaultRequestHeaders.Add('api-key', ApiKey);

        // BAD: bypasses Copilot capability registration, admin deactivation, data-movement consent and AI telemetry.
        Client.Post('https://contoso.openai.azure.com/openai/deployments/gpt/chat/completions?api-version=2024-10-21', Content, Response);
        Response.Content.ReadAs(ResponseText);
        exit(ResponseText);
    end;
}
