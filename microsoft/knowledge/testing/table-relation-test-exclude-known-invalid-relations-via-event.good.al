codeunit 50141 "Sample Table Relation Test Ext"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Table Relation Test", 'OnAfterRemoveTableRelation', '', false, false)]
    local procedure ExcludeSampleFieldFromTableRelationTest(var TableRelationsMetadata: Record "Table Relations Metadata" temporary)
    var
        TableRelationTest: Codeunit "Table Relation Test";
    begin
        TableRelationTest.RemoveTableRelation(TableRelationsMetadata, Database::"Sample Header", 10, Database::"Sample Setup", 1);
    end;
}
