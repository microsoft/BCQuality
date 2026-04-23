table 51113 "Style Sample Option Bad"
{
    fields
    {
        field(1; "Entry No."; Integer) { }
        field(10; Priority; Option)
        {
            // Four members, three captions. Critical renders with no caption.
            OptionMembers = Low,Medium,High,Critical;
            OptionCaption = 'Low,Medium,High';
        }
        field(20; Status; Option)
        {
            // Missing OptionCaption entirely.
            OptionMembers = Open,Released,Pending;
        }
    }
    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}
