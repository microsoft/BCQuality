table 50100 "Order Header"
{
    fields
    {
        field(1; "Entry No."; Integer)
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

    // No OnDelete. Deleting a header silently orphans every Order Line that
    // belonged to it. Nothing errors, and no page shows the stranded rows.
}

table 50101 "Order Line"
{
    fields
    {
        field(1; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "Header Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            // Reads like referential integrity. It is lookup and input validation
            // only: it propagates a RENAME of the parent key, and cascades nothing
            // on DELETE.
            TableRelation = "Order Header"."Entry No.";
        }
    }

    keys
    {
        key(PK; "Line No.")
        {
            Clustered = true;
        }
    }
}
