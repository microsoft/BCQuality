tableextension 50911 "Privacy Sample IS Bad" extends "Sales & Receivables Setup"
{
    fields
    {
        // Refactor moves the delta URL out of encrypted IsolatedStorage into a
        // plain table field. Value is now plaintext in SQL, unscoped, indistinguishable
        // from non-sensitive content.
        field(50100; "Delta Url"; Text[250])
        {
            DataClassification = EndUserPseudonymousIdentifiers;
        }
    }
}
