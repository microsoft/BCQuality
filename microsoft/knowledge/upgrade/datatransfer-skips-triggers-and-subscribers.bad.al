codeunit 50221 "Upgrade Standard Price"
{
    Subtype = Upgrade;

    local procedure ApplyStandardPrice()
    var
        PriceSchedule: Record "Upgrade Price Schedule";
        Transfer: DataTransfer;
    begin
        Transfer.SetTables(Database::"Upgrade Price Schedule", Database::"Upgrade Price Schedule");
        Transfer.AddConstantValue(50.0, PriceSchedule.FieldNo("Unit Price"));
        Transfer.CopyFields();
    end;
}

table 50223 "Upgrade Price Schedule"
{
    Caption = 'Upgrade Price Schedule';
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
                Amount := Quantity * "Unit Price";
            end;
        }
        field(4; Amount; Decimal)
        {
            Caption = 'Amount';
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
        "Outstanding Amount" := Amount - "Invoiced Amount";
    end;
}
