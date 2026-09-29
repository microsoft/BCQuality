table 50144 "Sample Setup"
{
    fields
    {
        field(1; "Primary Key"; Code[10]) { }
        field(2; "Default Category Code"; Code[20]) { }
    }
    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}

table 50145 "Sample Header"
{
    fields
    {
        field(1; "No."; Code[20]) { }
        field(10; "Category Code"; Code[10])
        {
            TableRelation = "Sample Setup"."Primary Key";
        }
        field(11; "Parent No."; Code[20])
        {
            TableRelation = "Sample Header"."No.";
        }
    }
    keys
    {
        key(PK; "No.") { Clustered = true; }
    }
}

codeunit 50141 "Sample Table Relation Test Ext"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Table Relation Test", 'OnAfterRemoveTableRelation', '', false, false)]
    local procedure ExcludeSampleFieldFromTableRelationTest(var TableRelationsMetadata: Record "Table Relations Metadata" temporary)
    var
        TableRelationTest: Codeunit "Table Relation Test";
    begin
        // Removes every relation on the whole table (field/related table/
        // related field all 0), not just the one known exception - this
        // also strips "Parent No." -> "Sample Header"."No.", which had no
        // exception and should have stayed covered by the standard test.
        TableRelationTest.RemoveTableRelation(TableRelationsMetadata, Database::"Sample Header", 0, 0, 0);
    end;
}
