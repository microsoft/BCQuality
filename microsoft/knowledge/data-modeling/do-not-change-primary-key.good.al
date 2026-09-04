table 50100 "Period Stats"
{
    fields
    {
        field(1; "Period Start"; Date) { }
    }
    keys
    {
        key(PK; "Period Start") { Clustered = true; }
    }
}

table 50101 "Period Stats By Flow"
{
    fields
    {
        field(1; "Period Start"; Date) { }
        field(2; Flow; Enum "Some Flow") { }
    }
    keys
    {
        key(PK; "Period Start") { Clustered = true; }
    }
}
