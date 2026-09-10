// Master data: Default Dimension records, no Dimension Set ID field.
table 50100 "Course"
{
    fields
    {
        field(1; "No."; Code[20]) { }
        field(10; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code where(
                "Global Dimension No." = const(1), Blocked = const(false));

            trigger OnValidate()
            var
                DimMgt: Codeunit DimensionManagement;
            begin
                DimMgt.ValidateDimValueCode(1, "Global Dimension 1 Code");
                DimMgt.SaveDefaultDim(Database::Course, "No.", FieldNo("Global Dimension 1 Code"), "Global Dimension 1 Code");
            end;
        }
    }

    trigger OnDelete()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.DeleteDefaultDim(Database::Course, "No.");
    end;
}

// Transactional/document data: a single Dimension Set ID, inherited from the
// related master record and overridable via shortcut dimension fields.
table 50101 "Course Registration Header"
{
    fields
    {
        field(1; "No."; Code[20]) { }
        field(2; "Customer No."; Code[20])
        {
            TableRelation = Customer;

            trigger OnValidate()
            begin
                UpdateDimensionSetID();
            end;
        }
        field(10; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code where(
                "Global Dimension No." = const(1), Blocked = const(false));

            trigger OnValidate()
            var
                DimMgt: Codeunit DimensionManagement;
            begin
                DimMgt.ValidateShortcutDimValues(1, "Shortcut Dimension 1 Code", "Dimension Set ID");
            end;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Editable = false;
            TableRelation = "Dimension Set Entry"."Dimension Set ID";
        }
    }

    local procedure UpdateDimensionSetID()
    var
        Customer: Record Customer;
        DimMgt: Codeunit DimensionManagement;
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
        GlobalDim2Code: Code[20];
    begin
        if not Customer.Get("Customer No.") then
            exit;

        DimMgt.AddDimSource(DefaultDimSource, Database::Customer, "Customer No.");
        "Dimension Set ID" :=
            DimMgt.GetDefaultDimID(
                DefaultDimSource, '', "Shortcut Dimension 1 Code", GlobalDim2Code, "Dimension Set ID", 0);
    end;
}
