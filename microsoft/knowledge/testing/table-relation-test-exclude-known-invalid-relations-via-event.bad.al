codeunit 50141 "Sample Table Relation Test Ext"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Table Relation Test", 'OnAfterRemoveTableRelation', '', false, false)]
    local procedure ExcludeSampleFieldFromTableRelationTest(var TableRelationsMetadata: Record "Table Relations Metadata" temporary)
    var
        TableRelationTest: Codeunit "Table Relation Test";
    begin
        // Removes every relation on the whole table, not just the one known exception
        TableRelationTest.RemoveTableRelation(TableRelationsMetadata, Database::"Sample Header", 0, 0, 0);
    end;
}
