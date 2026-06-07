// Best practice: a top-level API page whose entity names and version form a
// stable contract for an external agent, shaped read-only because the agent's
// workflow only needs to read. Demonstration-only; not a deployed object.

page 50120 "Agent Customer API"
{
    // Only top-level PageType = API pages surface as agent tools. A ListPart or
    // CardPart here would be silently unreachable by the agent.
    PageType = API;
    SourceTable = Customer;

    // These five properties are the contract. They are fixed literals, so the
    // route and the tool names the agent binds to never shift under it.
    APIPublisher = 'contoso';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    // EntityName and EntitySetName become the singular/plural tool names. They
    // use the agent's domain vocabulary, not the table's internal captions.
    EntityName = 'customer';
    EntitySetName = 'customers';

    // The agent only reads, so the whole surface is locked to read. A read tool
    // can never mutate, no matter what the prompt asks for.
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                // A narrow, deliberately chosen field set: exactly what the
                // agent reasons over, named for the agent, nothing more.
                field(number; Rec."No.") { Caption = 'number'; }
                field(displayName; Rec.Name) { Caption = 'displayName'; }
                field(city; Rec.City) { Caption = 'city'; }
                field(balanceDue; Rec."Balance Due (LCY)") { Caption = 'balanceDue'; }
            }
        }
    }
}
