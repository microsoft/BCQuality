table 50311 "Customer Profile Bad"
{
    fields
    {
        field(1; "No."; Code[20]) { }
        // Breaking: the published "Email" field was renamed in place. Dependent
        // extensions that reference "Email" stop compiling, and the data stored in
        // the old column is orphaned on upgrade.
        field(2; "Contact Email"; Text[80]) { }
    }
}
