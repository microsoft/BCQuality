table 50100 "Order Header"
{
    // The owning table needs delete rights on what it owns. Granting D only on the
    // header is a common miss and makes OnDelete fail for a non-SUPER user.
    Permissions = tabledata "Order Line" = rd;

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

    trigger OnDelete()
    var
        OrderLine: Record "Order Line";
    begin
        OrderLine.SetRange("Header Entry No.", "Entry No.");
        // Pass false only when Order Line has no OnDelete of its own.
        OrderLine.DeleteAll(true);
    end;
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
