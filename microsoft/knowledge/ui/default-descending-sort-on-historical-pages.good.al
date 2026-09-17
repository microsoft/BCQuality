page 50100 "Integration Log Entries"
{
    PageType = List;
    SourceTable = "Integration Log Entry";
    ApplicationArea = All;
    UsageCategory = History;
    Caption = 'Integration Log Entries';

    // Historical pages should open with the newest records first.
    SourceTableView = order(descending);

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field(Message; Rec.Message)
                {
                }
            }
        }
    }
}