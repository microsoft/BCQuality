// Demonstration only; independently authored, not copied from BaseApp.
codeunit 50103 "Change Journal Dimension"
{
    procedure ChangeExistingDimension(TemplateName: Code[10]; BatchName: Code[10]; LineNo: Integer; DimensionCode: Code[20]; NewValue: Code[20])
    var
        JournalLine: Record "Gen. Journal Line";
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionManagement: Codeunit DimensionManagement;
    begin
        JournalLine.Get(TemplateName, BatchName, LineNo);
        DimensionManagement.GetDimensionSet(TempDimensionSetEntry, JournalLine."Dimension Set ID");
        TempDimensionSetEntry.Get(JournalLine."Dimension Set ID", DimensionCode);
        TempDimensionSetEntry.Validate("Dimension Value Code", NewValue);
        TempDimensionSetEntry.Modify();
        JournalLine.Validate("Dimension Set ID", DimensionManagement.GetDimensionSetID(TempDimensionSetEntry));
        JournalLine.Modify(true);
    end;
}
