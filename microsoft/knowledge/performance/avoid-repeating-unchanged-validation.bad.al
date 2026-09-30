// Quantity validation depends only on Quantity and Unit Price in this demo.
table 50371 "Perf Validated Line"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Line No."; Integer) { }
        field(2; Quantity; Decimal)
        {
            trigger OnValidate()
            begin
                Amount := Quantity * "Unit Price";
            end;
        }
        field(3; "Unit Price"; Decimal) { }
        field(4; Amount; Decimal) { }
        field(5; Note; Text[100]) { }
    }

    keys
    {
        key(PK; "Line No.") { Clustered = true; }
    }
}

codeunit 50372 "Perf Validation Bad"
{
    procedure UpdateLine(LineNo: Integer; NewQuantity: Decimal; NewNote: Text[100])
    var
        Line: Record "Perf Validated Line";
    begin
        Line.Get(LineNo);
        Line.Validate(Quantity, NewQuantity);
        Line.Note := NewNote;
        Line.Validate(Quantity, NewQuantity);
        Line.Modify(false);
    end;
}
