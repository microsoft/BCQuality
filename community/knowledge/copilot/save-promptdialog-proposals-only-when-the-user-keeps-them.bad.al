// Demonstration only. Shows the wrong pattern: the Generate action writes the proposal to real records.

page 50210 "Copilot Item Description Bad"
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
                var
                    Item: Record Item;
                begin
                    ProposedDescription := DescriptionGenerator.Generate(ItemNo, Tone);
                    // BAD: the proposal is saved before the user chooses Keep it or Discard.
                    Item.Get(ItemNo);
                    Item."Description 2" := CopyStr(ProposedDescription, 1, MaxStrLen(Item."Description 2"));
                    Item.Modify(true);
                end;
            }
        }
    }

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
