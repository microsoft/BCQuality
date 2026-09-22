namespace Contoso.Extensions;

using System.Performance; // guessed; never verified against the source file

codeunit 50100 "Tooling Extension"
{
    procedure Run()
    var
        ToolingPage: Page "Some Tooling Page"; // guessed namespace; can still resolve against a stale or cached symbol package, then fail once checked against the object's current source or a freshly downloaded one
    begin
        ToolingPage.Run();
    end;
}
