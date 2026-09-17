table 50123 "Transfer Source Bad"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "Reference"; Code[20])
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

table 50124 "Transfer Target Bad"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "Reference"; Integer)
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

codeunit 50492 "TransferFields Bad"
{
    procedure CopyData(Source: Record "Transfer Source Bad"; var Target: Record "Transfer Target Bad")
    begin
        Target.TransferFields(Source, true, true);
    end;
}