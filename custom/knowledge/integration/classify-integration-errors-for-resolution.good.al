// Best practice: on failure, classify the error into one of three actionable
// classes and store it on the Integration Message. Ops then sees a sorted queue
// instead of a wall of raw error text. Rules cover the known codes; an AI
// classifier (via System.AI) buckets the free-text remainder. The class only
// routes the work, it never auto-resolves it.

enum 50135 "Integration Error Class"
{
    Extensible = true;

    value(0; Unclassified) { Caption = 'Unclassified'; }
    value(10; DataError) { Caption = 'Data error'; }        // a human fixes the payload
    value(20; Transient) { Caption = 'Transient'; }         // the scheduled retry heals it
    value(30; ContractChange) { Caption = 'Contract change'; } // escalate to the owner
}

codeunit 50140 "Classify Integration Error"
{
    // Called on the failure path, after Status has been set to Failed.
    procedure Classify(var IntegrationMessage: Record "Integration Message")
    var
        AIClassifier: Codeunit "AI Classifier Wrapper";
        Class: Enum "Integration Error Class";
    begin
        // 1) Fast path: deterministic rules over codes we already recognise.
        Class := ClassifyByKnownCodes(IntegrationMessage."Error Code");

        // 2) Fall back to the AI classifier for the free-text messages rules miss.
        //    The wrapper calls the model through the System.AI module, so the call
        //    is governed and billed, not a raw HttpClient to a model endpoint.
        if Class = Class::Unclassified then
            Class := AIClassifier.Classify(IntegrationMessage."Error Message", IntegrationMessage.Type);

        // 3) Store the class so the resolution page can route on it. Advisory only:
        //    a human still confirms a data fix, the retry job still owns transient.
        IntegrationMessage."Error Class" := Class;
        IntegrationMessage.Modify(true);
    end;
}
