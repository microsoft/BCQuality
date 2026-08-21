table 50121 "Transfer Source"
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

table 50122 "Transfer Target"
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

codeunit 50491 "TransferFields Good"
{
    procedure CopyData(Source: Record "Transfer Source"; var Target: Record "Transfer Target")
    var
        ConvertedReference: Integer;
    begin
        Target."Entry No." := Source."Entry No.";
        Evaluate(ConvertedReference, Source."Reference");
        Target.Validate("Reference", ConvertedReference);
    end;
}
