enum 50100 "Sample Source Type"
{
    Extensible = true;

    value(0; Category) { }
    value(1; Region) { }
}

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

table 50101 "Sample Region"
{
    fields
    {
        field(1; "Code"; Code[10]) { }
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
        // Unconditional relation: same type and exactly the same length as
        // "Sample Category"."Code".
        field(2; "Category Code"; Code[20])
        {
            TableRelation = "Sample Category"."Code";
        }
        field(3; "Source Type"; Enum "Sample Source Type") { }
        // All branches conditional: at least as long as the longest related
        // field (Code[20] covers both Code[20] and Code[10]).
        field(4; "Source Code"; Code[20])
        {
            TableRelation = if ("Source Type" = const(Category)) "Sample Category"."Code"
            else
            if ("Source Type" = const(Region)) "Sample Region"."Code";
        }
        // Filter field: holds a filter expression, not one code, so it is
        // deliberately longer and opts out of relation validation.
        field(5; "Category Filter"; Code[250])
        {
            TableRelation = "Sample Category"."Code";
            ValidateTableRelation = false;
        }
    }
    keys
    {
        key(PK; "Code") { Clustered = true; }
    }
}
