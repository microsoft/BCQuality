table 50438 "Source Media Good"
{
    fields
    {
        field(1; Code; Code[20]) { }
        field(10; Pictures; MediaSet) { }
    }
}

table 50439 "Target Media Good"
{
    fields
    {
        field(1; Code; Code[20]) { }
        field(20; Pictures; MediaSet) { }
    }
}

codeunit 50440 "Share Media Good"
{
    procedure CopyPictures(Source: Record "Source Media Good"; var Target: Record "Target Media Good")
    var
        Index: Integer;
    begin
        for Index := 1 to Source.Pictures.Count() do
            Target.Pictures.Insert(Source.Pictures.Item(Index));
        Target.Modify(true);
    end;
}
