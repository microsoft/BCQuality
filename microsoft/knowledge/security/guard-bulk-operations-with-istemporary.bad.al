codeunit 50100 "Order Buffer Helper"
{
    procedure ResetStagingBuffer(var OrderBuffer: Record "Sales Header")
    begin
        // No IsTemporary check. A caller that accidentally passes the real
        // Sales Header table wipes every sales header in the company with
        // no prior warning.
        OrderBuffer.DeleteAll();
    end;
}
