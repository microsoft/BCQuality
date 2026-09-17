table 50441 "Source Media Bad"
{
    fields
    {
        field(1; Code; Code[20]) { }
        field(10; Pictures; MediaSet) { }
    }
}

table 50442 "Target Media Bad"
{
    fields
    {
        field(1; Code; Code[20]) { }
        field(20; Pictures; MediaSet) { }
    }
}

codeunit 50443 "Share Media Bad"
{
    procedure CopyPictures(Source: Record "Source Media Bad"; var Target: Record "Target Media Bad")
    begin
        Target.Pictures := Source.Pictures;
        Target.Modify(true);
    end;
}
