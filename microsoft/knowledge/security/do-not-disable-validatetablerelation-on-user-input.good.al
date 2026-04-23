tableextension 51302 "Sec Sample VTR Good" extends "Sales Header"
{
    fields
    {
        // User-editable field keeps ValidateTableRelation default (true).
        field(50100; "External Customer Ref"; Code[50])
        {
            Caption = 'External customer reference';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }

        // System-controlled field: validation bypass is acceptable because
        // the value is populated by controlled upstream code, not the user.
        field(50101; "System Batch Id"; Code[20])
        {
            Caption = 'System batch ID';
            DataClassification = SystemMetadata;
            TableRelation = "Job Queue Entry".ID;
            ValidateTableRelation = false;
            Editable = false;
        }
    }
}
