table 50100 "Course"
{
    fields
    {
        field(1; "No."; Code[20]) { }
        field(10; "Global Dimension 1 Code"; Code[20])
        {
            // No CaptionClass, no OnValidate call into DimensionManagement.
            // Accepts any value; never becomes a Default Dimension record.
            TableRelation = "Dimension Value".Code;
        }
    }
}
