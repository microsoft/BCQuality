table 50100 "Customer Feedback"
{
    fields
    {
        field(1; "Feedback No."; Code[20])
        {
            // No DataClassification declared. Defaults to ToBeClassified.
        }
        field(2; "Contact Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Email"; Text[80])
        {
            // Personal data classified as CustomerContent understates privacy impact.
            DataClassification = CustomerContent;
        }
        field(4; "Feedback Text"; Text[2048])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Feedback No.") { Clustered = true; }
    }
}
