table 50120 "Source Document"
{
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    // "Source Key" below cannot declare a TableRelation, so the platform cannot
    // repoint it. The owning table carries the relationship by hand.
    trigger OnRename()
    var
        DocumentLink: Record "Document Link";
    begin
        // In OnRename, xRec holds the PREVIOUS primary key while Rec holds the new
        // one — the one trigger where that is true regardless of what drove the rename.
        DocumentLink.SetRange("Source Key", MakeSourceKey(xRec."No."));
        if DocumentLink.FindSet(true) then
            repeat
                DocumentLink."Source Key" := MakeSourceKey(Rec."No.");
                DocumentLink.Modify(true);
            until DocumentLink.Next() = 0;
    end;

    local procedure MakeSourceKey(DocumentNo: Code[20]): Code[50]
    begin
        exit(StrSubstNo('DOC|%1', DocumentNo));
    end;
}

table 50121 "Document Link"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        // Default ValidateTableRelation: the platform repoints this on rename.
        field(2; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Source Document"."No.";
        }
        // Composite value — no TableRelation can express it, so the parent's
        // OnRename above maintains it explicitly.
        field(3; "Source Key"; Code[50])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
