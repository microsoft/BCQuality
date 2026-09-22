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
        // A known exception: "Category Code" predates "Sample Setup" and
        // can carry a value that no longer resolves to a real row there,
        // so the standard Table Relation Test would otherwise reject it -
        // excluded via OnAfterRemoveTableRelation below.
        field(10; "Category Code"; Code[10])
        {
            TableRelation = "Sample Setup"."Primary Key";
        }
        // An ordinary relation with no exception - ExcludeSampleFieldFrom
        // TableRelationTest below must leave this one checked.
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
        // Removes only the one known exception. "Parent No." -> "Sample
        // Header"."No." is untouched and stays covered by the standard test.
        TableRelationTest.RemoveTableRelation(TableRelationsMetadata, Database::"Sample Header", 10, Database::"Sample Setup", 1);
    end;
}
