table 50100 "Sample Category"
{
    fields
    {
        field(1; "Code"; Code[20]) { }
    }
    keys
    {
        key(PK; "Code") { Clustered = true; }
    }
}

table 50102 "Sample Contract"
{
    fields
    {
        field(1; "Code"; Code[20]) { }
        // Code[10] cannot hold every "Sample Category"."Code" value (Code[20]).
        // Compiles without a diagnostic; assigning or validating a category code
        // longer than 10 characters fails at runtime.
        field(2; "Category Code"; Code[10])
        {
            TableRelation = "Sample Category"."Code";
        }
    }
    keys
    {
        key(PK; "Code") { Clustered = true; }
    }
}
