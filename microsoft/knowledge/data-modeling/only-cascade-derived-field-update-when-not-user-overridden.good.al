table 50800 "Equipment Model"
{
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[100])
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                // Recompute only while "Search Name" is blank or still equals the
                // transform of the previous Name; any other value is a user override.
                if ("Search Name" = UpperCase(xRec.Name)) or ("Search Name" = '') then
                    "Search Name" := Name;
            end;
        }
        // Editable by design: users may type their own search alias here.
        field(3; "Search Name"; Code[100])
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies an alternate name that you can use to search for the equipment model.';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Search; "Search Name")
        {
        }
    }
}
