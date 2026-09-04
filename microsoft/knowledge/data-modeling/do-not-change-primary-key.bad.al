table 50100 "Period Stats"
{
    fields
    {
        field(1; "Period Start"; Date) { }
        field(2; Flow; Enum "Some Flow") { }
    }
    keys
    {
        // Table already shipped with key(PK; "Period Start").
        // Adding Flow here breaks every upgrade with AS0009.
        key(PK; Flow, "Period Start") { Clustered = true; }
    }
}
