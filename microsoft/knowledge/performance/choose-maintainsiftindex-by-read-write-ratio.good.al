table 50100 "Item Ledger Entry (Demo)"
{
    fields
    {
        field(1; "Entry No."; Integer) { DataClassification = SystemMetadata; }
        field(2; "Item No."; Code[20]) { DataClassification = CustomerContent; }
        field(3; "Posting Date"; Date) { DataClassification = CustomerContent; }
        field(4; Quantity; Decimal) { DataClassification = CustomerContent; }
        field(5; "Cost Amount"; Decimal) { DataClassification = CustomerContent; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }

        // Write-heavy ledger key: aggregates on this key are read rarely relative
        // to INSERT frequency. Keeping SIFT live on every write is net-negative.
        key(ByItemAndDate; "Item No.", "Posting Date")
        {
            SumIndexFields = Quantity, "Cost Amount";
            MaintainSIFTIndex = false;
        }

        // Dashboard-facing key: aggregates read on every session load, underlying
        // rows updated infrequently. Keeping SIFT live pays for itself.
        key(ByItem; "Item No.")
        {
            SumIndexFields = Quantity;
            MaintainSIFTIndex = true;
        }
    }
}
