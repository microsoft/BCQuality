enum 50100 "Course Difficulty"
{
    Extensible = true;

    value(0; Beginner) { }
    value(1; Intermediate) { }
    value(2; Advanced) { }
}

table 50101 "Course"
{
    fields
    {
        field(1; "No."; Code[20]) { }
        field(10; Difficulty; Enum "Course Difficulty") { }
    }
}
