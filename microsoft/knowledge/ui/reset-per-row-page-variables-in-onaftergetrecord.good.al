page 50390 "UI Item Outputs Good"
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
        Clear(ItemMasterDescription);
        Clear(ItemPostingGroup);
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

// Complete assignment is equally valid without explicit Clear calls.
page 50392 "UI Item Outputs Complete"
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
        if (Rec.Type = Rec.Type::Item) and Item.Get(Rec."No.") then begin
            ItemMasterDescription := Item.Description;
            ItemPostingGroup := Item."Inventory Posting Group";
        end else begin
            ItemMasterDescription := '';
            ItemPostingGroup := '';
        end;
    end;
    var
        ItemMasterDescription: Text[100];
        ItemPostingGroup: Code[20];
}
