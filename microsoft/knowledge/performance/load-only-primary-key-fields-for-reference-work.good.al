codeunit 50100 "Item Reindex Queue"
{
    procedure QueueItemsForReindex(CategoryCode: Code[20])
    var
        Item: Record Item;
        ReindexQueue: Codeunit "Reindex Queue";
    begin
        // Only the primary key is used in the loop body; load nothing else.
        Item.SetRange("Item Category Code", CategoryCode);
        Item.SetLoadFields("No.");

        if Item.FindSet() then
            repeat
                ReindexQueue.Enqueue(Item."No.");
            until Item.Next() = 0;
    end;
}
