table 50540 "Sample Shipping Agent Bad"
{
    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        TestField(Description);
    end;
}

page 50541 "Sample Shipping Agents Bad"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Sample Shipping Agent Bad";
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Agents)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the shipping agent.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the shipping agent.';
                    // Required by OnInsert, but nothing marks it. The user types
                    // the row, leaves it, and only then gets the error.
                }
            }
        }
    }
}
