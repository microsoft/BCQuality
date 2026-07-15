enum 50434 "Relation Type Bad"
{
    Extensible = true;

    value(0; Customer) { }
}

table 50435 "Related Entity Bad"
{
    fields
    {
        field(1; Type; Enum "Relation Type Bad") { }
        field(2; "Related No."; Code[20])
        {
            // This unconditional relation wins before extension branches run.
            TableRelation = Customer;
        }
    }
}

enumextension 50436 "Relation Type Bad Ext" extends "Relation Type Bad"
{
    value(10; Resource) { }
}

tableextension 50437 "Related Entity Bad Ext" extends "Related Entity Bad"
{
    fields
    {
        modify("Related No.")
        {
            TableRelation = if (Type = const(Resource)) Resource;
        }
    }
}
