// Demonstration only; independently authored, not copied from BaseApp.
codeunit 50102 "Copy Journal Dimensions"
{
    procedure CopyAllLineDimensions(TemplateName: Code[10]; BatchName: Code[10]; SourceLineNo: Integer; TargetLineNo: Integer)
    var
        SourceLine: Record "Gen. Journal Line";
        TargetLine: Record "Gen. Journal Line";
    begin
        SourceLine.Get(TemplateName, BatchName, SourceLineNo);
        TargetLine.Get(TemplateName, BatchName, TargetLineNo);
        TargetLine.Validate("Dimension Set ID", SourceLine."Dimension Set ID");
        TargetLine.Modify(true);
    end;

    procedure HasShortcutDimension1(JournalLine: Record "Gen. Journal Line"; DimensionValue: Code[20]): Boolean
    begin
        exit(JournalLine."Shortcut Dimension 1 Code" = DimensionValue);
    end;
}
