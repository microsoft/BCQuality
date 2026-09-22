table 50101 "Course"
{
    fields
    {
        field(1; "No."; Code[20]) { }
        // 1 = Beginner, 2..3 = Intermediate, 4+ = Advanced
        field(10; Difficulty; Integer) { }
    }
}

codeunit 50100 "Course Level Helper"
{
    procedure LevelText(Difficulty: Integer): Text
    begin
        case Difficulty of
            1:
                exit('Beginner');
            2, 3:
                exit('Intermediate');
        end;
    end;
}
