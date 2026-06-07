// Anti-pattern: an unstable, over-broad agent surface. The version is not a
// fixed contract, the entity is exposed through a part page the agent cannot
// see, and every write is left open. Demonstration-only.

// Smell 1: a ListPart can never surface as an agent tool. Only top-level API
// pages are picked up, so this entity is silently unreachable.
page 50121 "Agent Customer Part"
{
    PageType = ListPart;
    SourceTable = Customer;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(no; Rec."No.") { }
                field(name; Rec.Name) { }
            }
        }
    }
}

// Smell 2: a top-level API page that is over-broad and unstable.
page 50122 "Agent Vendor API"
{
    PageType = API;
    SourceTable = Vendor;
    APIPublisher = 'contoso';
    APIGroup = 'purchasing';
    // The version is bumped in place on each change instead of adding a new one,
    // so every tool the agent discovered against v1.0 stops resolving.
    APIVersion = 'v2.0';
    EntityName = 'vendor';
    EntitySetName = 'vendors';

    // Nothing is locked down. A read-only agent workflow still gets create,
    // modify, and delete tools, so a mistaken or prompt-injected agent can
    // mutate or delete vendors it had no business touching.
    // InsertAllowed / ModifyAllowed / DeleteAllowed left at permissive defaults.

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                // The entire table sprayed out, far beyond what the agent needs,
                // widening the schema and the write blast radius for no reason.
                field(no; Rec."No.") { }
                field(name; Rec.Name) { }
                field(blocked; Rec.Blocked) { }
                field(balance; Rec."Balance (LCY)") { }
                field(iban; Rec.IBAN) { }
                field(paymentTerms; Rec."Payment Terms Code") { }
            }
        }
    }
}
