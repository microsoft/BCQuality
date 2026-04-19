codeunit 50100 "Item Reindex Queue"
{
    procedure QueueItemsForReindex(CategoryCode: Code[20])
    var
        Item: Record Item;
        ReindexQueue: Codeunit "Reindex Queue";
    begin
        // Default full-record load. Description, Unit Price, Inventory, and
        // every other column are fetched across the wire and held in memory
        // for the whole loop - the body only ever reads "No.".
        Item.SetRange("Item Category Code", CategoryCode);

        if Item.FindSet() then
            repeat
                ReindexQueue.Enqueue(Item."No.");
            until Item.Next() = 0;
    end;
}
