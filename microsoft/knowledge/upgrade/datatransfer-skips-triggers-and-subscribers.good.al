codeunit 50220 "Upgrade Price Calculation"
{
    Subtype = Upgrade;

    local procedure UpdateUnitPrice()
    var
        PriceLine: Record "Upgrade Price Line";
    begin
        if PriceLine.FindSet(true) then
            repeat
                PriceLine.Validate("Unit Price", 50.0);
                PriceLine.Modify(true);
            until PriceLine.Next() = 0;
    end;
}

table 50223 "Upgrade Price Line"
{
    Caption = 'Upgrade Price Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(3; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';

            trigger OnValidate()
            begin
                "Line Amount" := Quantity * "Unit Price";
            end;
        }
        field(4; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
        }
        field(5; "Invoiced Amount"; Decimal)
        {
            Caption = 'Invoiced Amount';
        }
        field(6; "Outstanding Amount"; Decimal)
        {
            Caption = 'Outstanding Amount';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    trigger OnModify()
    begin
        "Outstanding Amount" := "Line Amount" - "Invoiced Amount";
    end;
}
