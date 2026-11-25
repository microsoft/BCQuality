// All objects are in the same app, on a platform supporting same-app extraction.
// The extension members below previously lived in their corresponding base objects.
table 50170 "Extraction Source"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; "No."; Code[20]) { }
    }
    keys
    {
        key(PK; "No.") { Clustered = true; }
    }
}

tableextension 50171 "Extracted Table Members" extends "Extraction Source"
{
    fields
    {
        // Same field ID, name, and type as before extraction.
        field(2; "Extra Value"; Decimal) { }
    }

    var
        LastValue: Decimal;

    procedure GetExtraValue(): Decimal
    begin
        LastValue := "Extra Value";
        exit(LastValue);
    end;
}

page 50170 "Extraction Card"
{
    PageType = Card;
    SourceTable = "Extraction Source";
    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
            }
        }
    }
}

pageextension 50171 "Extracted Page Members" extends "Extraction Card"
{
    layout
    {
        addafter("No.")
        {
            field(ExtraValue; Rec."Extra Value") { ApplicationArea = All; }
        }
    }

    var
        LastValue: Decimal;

    procedure GetExtraValue(): Decimal
    begin
        LastValue := Rec.GetExtraValue();
        exit(LastValue);
    end;
}

report 50170 "Extraction Report"
{
    ProcessingOnly = true;
    dataset
    {
        dataitem(Source; "Extraction Source")
        {
            column(No; "No.") { }
        }
    }
}

reportextension 50171 "Extracted Report Members" extends "Extraction Report"
{
    dataset
    {
        add(Source)
        {
            column(ExtraValue; "Extra Value") { }
        }
    }

    var
        LastValue: Decimal;

    procedure SetExtraValue(NewValue: Decimal)
    begin
        LastValue := NewValue;
    end;

    procedure GetExtraValue(): Decimal
    begin
        exit(LastValue);
    end;
}
