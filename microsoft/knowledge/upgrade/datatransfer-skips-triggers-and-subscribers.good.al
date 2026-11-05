codeunit 50220 "Upgrade Standard Price"
{
    Subtype = Upgrade;

    local procedure ApplyStandardPrice()
    var
        PriceSchedule: Record "Upgrade Price Schedule";
    begin
        if PriceSchedule.FindSet(true) then
            repeat
                PriceSchedule.Validate("Unit Price", 50.0);
                PriceSchedule.Modify(true);
            until PriceSchedule.Next() = 0;
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
