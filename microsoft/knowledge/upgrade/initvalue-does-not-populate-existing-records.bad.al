tableextension 50812 "Upgrade Sample InitValue Bad" extends Customer
{
    fields
    {
        field(50101; "Is Active"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Is active';
            // InitValue applies to new records only.
            // Every existing customer remains Is Active = false after the upgrade.
            InitValue = true;
        }
    }
}
