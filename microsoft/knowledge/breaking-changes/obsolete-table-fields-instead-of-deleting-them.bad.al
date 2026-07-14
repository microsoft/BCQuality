table 50311 "Customer Profile Bad"
{
    fields
    {
        field(1; "No."; Code[20]) { }
        // Breaking: the published field was renamed while retaining ID 2.
        // AppSourceCop AS0005 rejects the compatibility change; retaining the ID
        // does not by itself mean the stored column was dropped and re-created.
        field(2; "Contact Email"; Text[80]) { }
    }
}
