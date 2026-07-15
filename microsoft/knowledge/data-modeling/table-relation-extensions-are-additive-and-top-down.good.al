enum 50430 "Relation Type Good"
{
    Extensible = true;

    value(0; Customer) { }
    value(1; Item) { }
}

table 50431 "Related Entity Good"
{
    fields
    {
        field(1; Type; Enum "Relation Type Good") { }
        field(2; "Related No."; Code[20])
        {
            TableRelation =
                if (Type = const(Customer)) Customer
                else if (Type = const(Item)) Item;
        }
    }
}

enumextension 50432 "Relation Type Resource" extends "Relation Type Good"
{
    value(10; Resource) { }
}

tableextension 50433 "Related Entity Resource" extends "Related Entity Good"
{
    fields
    {
        modify("Related No.")
        {
            TableRelation = if (Type = const(Resource)) Resource;
        }
    }
}
