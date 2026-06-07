// Anti-pattern: one handler runs every step in a single transaction, and a SingleInstance
// codeunit holds lookups that leak across runs. One big lock, one big rollback, and stages
// that should be independent are coupled through shared state.

codeunit 50213 "Monolithic Flow Bad"
{
    procedure RunAll(var IntegrationMessage: Record "Integration Message")
    begin
        // BAD: fetch, transform, post, and notify all run in ONE transaction. Every lock any step
        // takes is held until the final step commits, so the slowest/most contended step sets the
        // lock duration for all of them.
        Fetch(IntegrationMessage);
        Transform(IntegrationMessage);

        // If Post fails, Fetch and Transform ROLL BACK with it: their successful work is discarded
        // and the whole flow must re-run from the start, redoing work that had already succeeded.
        Post(IntegrationMessage);

        // A transient hiccup HERE, after a perfectly good post, throws away that post too, because
        // it is all one transaction. The unit of failure is the entire flow, not the failing step.
        Notify(IntegrationMessage);
    end;
}

codeunit 50214 "Cross Stage Cache Bad"
{
    SingleInstance = true; // BAD: a global cache that survives between stage runs couples the stages
    var
        ItemCache: Dictionary of [Code[20], Code[20]];

    procedure Lookup(ItemNo: Code[20]): Code[20]
    begin
        // BAD: stages that read this cache now depend on whichever earlier run populated it. They
        // can no longer be retried or reordered in isolation, which is exactly the independence a
        // staged split is supposed to give. Wanting a cache this global is the tell the split is wrong.
        exit(ItemCache.Get(ItemNo));
    end;
}
