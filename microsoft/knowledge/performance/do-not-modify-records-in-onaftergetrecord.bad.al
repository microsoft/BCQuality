pageextension 51209 "Perf Sample NoModifyOAGR Bad" extends "Customer List"
{
    trigger OnAfterGetRecord()
    begin
        // Every scroll writes to the database. Every OnModify subscriber on
        // Customer fires alongside. Write volume scales with mouse-wheel speed.
        Rec."Last Warning Flag" := CalcWarning();
        Rec.Modify();
    end;

    local procedure CalcWarning(): Boolean
    begin
        exit(false);
    end;
}
