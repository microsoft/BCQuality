table 50100 "Customer Feedback"
{
    fields
    {
        field(1; "Feedback No."; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Contact Name"; Text[100])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Email"; Text[80])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Product Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(5; "Feedback Text"; Text[2048])
        {
            // When uncertain between CustomerContent and EUII, prefer the stronger protection.
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "Submitted DateTime"; DateTime)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Feedback No.") { Clustered = true; }
    }
}
