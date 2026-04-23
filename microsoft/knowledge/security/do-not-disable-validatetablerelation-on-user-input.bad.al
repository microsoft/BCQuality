tableextension 51303 "Sec Sample VTR Bad" extends "Sales Header"
{
    fields
    {
        // Editable user input with validation suppressed and no fallback check.
        // The user can type any string; downstream Get against Customer will fail
        // or return a wrong row.
        field(50102; "Customer No."; Code[20])
        {
            Caption = 'Customer no.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
            ValidateTableRelation = false;
        }
    }
}
