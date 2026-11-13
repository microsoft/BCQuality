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
                // Overwrites whatever the user typed into "Search Name".
                "Search Name" := Name;
            end;
        }
        // Editable: a user can enter an alias, which the next Name change destroys.
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
