// Demonstration only; independently authored, not copied from BaseApp.
codeunit 50103 "Change Journal Dimension"
{
    procedure ChangeExistingDimension(TemplateName: Code[10]; BatchName: Code[10]; LineNo: Integer; DimensionCode: Code[20]; NewValue: Code[20])
    var
        JournalLine: Record "Gen. Journal Line";
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        JournalLine.Get(TemplateName, BatchName, LineNo);
        DimensionSetEntry.Get(JournalLine."Dimension Set ID", DimensionCode);
        DimensionSetEntry.Validate("Dimension Value Code", NewValue);
        DimensionSetEntry.Modify();
    end;
}
