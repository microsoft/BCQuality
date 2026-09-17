table 50121 "Document Link"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Source Document"."No.";
            // Added to silence a validation error while the row is staged, before
            // the Source Document exists. The relation is still declared, so this
            // reads as harmless — but it also switches OFF rename propagation.
            // Renaming a Source Document now leaves this field on the old key,
            // with no error, and nothing else maintains it.
            ValidateTableRelation = false;
        }
        // Composite value: no TableRelation is possible, and no OnRename on the
        // owning table maintains it either. Rots the same way, for the other reason.
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
