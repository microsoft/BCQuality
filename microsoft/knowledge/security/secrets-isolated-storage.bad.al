table 50134 "Api Setup Bad Sample"
{
    fields
    {
        field(1; "Primary Key"; Code[10]) { }

        // A secret in an ordinary Text field is readable by anyone with table
        // permission, ships in RapidStart packages and Excel exports, and
        // appears in record snapshots. No DataClassification tag makes it safe;
        // it belongs in IsolatedStorage instead.
        field(10; "API Key"; Text[250])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}
