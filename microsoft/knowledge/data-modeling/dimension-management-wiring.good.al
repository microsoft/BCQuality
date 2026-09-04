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
                DimMgt.ValidateShortcutDimCode(1, "Global Dimension 1 Code");
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
