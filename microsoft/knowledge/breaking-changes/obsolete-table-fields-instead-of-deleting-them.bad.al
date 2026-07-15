table 50311 "Customer Profile Bad"
{
    fields
    {
        field(1; "No."; Code[20]) { }
        // Breaking: the published Email field at ID 3 was renamed while retaining
        // the ID. The good example keeps Email at ID 3 and adds a separate field.
        // AppSourceCop AS0005 rejects the compatibility change; retaining the ID
        // does not by itself mean the stored column was dropped and re-created.
        field(3; "Contact Email"; Text[80]) { }
    }
}
