// Demonstration only. Shows the recommended pattern: the proposal stays in a page variable until the user keeps it.

page 50211 "Copilot Item Description Good"
{
    PageType = PromptDialog;
    Extensible = false;
    Caption = 'Draft item description with Copilot';

    layout
    {
        area(Prompt)
        {
            field(ToneField; Tone) { ShowCaption = false; MultiLine = true; }
        }
        area(Content)
        {
            field(DescriptionField; ProposedDescription) { ShowCaption = false; MultiLine = true; }
        }
    }

    actions
    {
        area(SystemActions)
        {
            systemaction(Generate)
            {
                trigger OnAction()
                begin
                    ProposedDescription := DescriptionGenerator.Generate(ItemNo, Tone);
                end;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        Item: Record Item;
    begin
        if CloseAction <> Action::OK then
            exit(true);
        Item.Get(ItemNo);
        Item.Validate("Description 2", CopyStr(ProposedDescription, 1, MaxStrLen(Item."Description 2")));
        Item.Modify(true);
        exit(true);
    end;

    procedure SetItem(NewItemNo: Code[20])
    begin
        ItemNo := NewItemNo;
    end;

    var
        DescriptionGenerator: Codeunit "Item Description Generator";
        ItemNo: Code[20];
        Tone: Text;
        ProposedDescription: Text;
}
