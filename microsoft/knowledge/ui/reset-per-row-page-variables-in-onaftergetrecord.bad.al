page 50391 "UI Item Outputs Bad"
{
    PageType = ListPart;
    SourceTable = "Sales Line";
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field(itemMasterDescription; ItemMasterDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Item Master Description';
                    ToolTip = 'Specifies the current item description, or blank for a line without an item.';
                }
                field(itemPostingGroup; ItemPostingGroup)
                {
                    ApplicationArea = All;
                    Caption = 'Item Posting Group';
                    ToolTip = 'Specifies the item inventory posting group, or blank for a line without an item.';
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    var
        Item: Record Item;
    begin
// A non-item line after an item line can retain the item outputs.
        if Rec.Type <> Rec.Type::Item then
            exit;
        if not Item.Get(Rec."No.") then
            exit;
        ItemMasterDescription := Item.Description;
        ItemPostingGroup := Item."Inventory Posting Group";
    end;
    var
        ItemMasterDescription: Text[100];
        ItemPostingGroup: Code[20];
}
