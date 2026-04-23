table 51112 "Style Sample Option Good"
{
    fields
    {
        field(1; "Entry No."; Integer) { }
        field(10; Priority; Option)
        {
            OptionMembers = Low,Medium,High,Critical;
            OptionCaption = 'Low,Medium,High,Critical';
        }
        field(20; Status; Option)
        {
            OptionMembers = Open,Released,Pending;
            OptionCaption = 'Open,Released,Pending';
        }
    }
    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}
