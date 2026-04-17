codeunit 50140 "Perf Sample Subscriber Bad"
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure HeavyWorkOnSalesLineNo(var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
    var
        HttpClient: HttpClient;
        HttpResponse: HttpResponseMessage;
    begin
        // synchronous external call on a hot event
        HttpClient.Get('https://example.com/validate?no=' + Rec."No.", HttpResponse);
    end;
}
