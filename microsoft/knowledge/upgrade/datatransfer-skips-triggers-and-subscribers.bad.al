codeunit 50221 "Upgrade Price Calculation"
{
    Subtype = Upgrade;

    local procedure UpdateUnitPrice()
    var
        PriceLine: Record "Upgrade Price Line";
        Transfer: DataTransfer;
    begin
        Transfer.SetTables(Database::"Upgrade Price Line", Database::"Upgrade Price Line");
        Transfer.AddConstantValue(50.0, PriceLine.FieldNo("Unit Price"));
        Transfer.CopyFields();
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
