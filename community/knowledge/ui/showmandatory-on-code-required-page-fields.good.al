table 50542 "Sample Shipping Agent"
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

page 50543 "Sample Shipping Agents"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Sample Shipping Agent";
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
                    ShowMandatory = true;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the shipping agent.';
                    // Mirrors the TestField in OnInsert. ShowMandatory is what the
                    // client reads for the marker, so it has to be set here.
                    ShowMandatory = true;
                }
            }
        }
    }
}
