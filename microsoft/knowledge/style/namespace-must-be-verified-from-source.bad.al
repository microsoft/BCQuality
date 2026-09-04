namespace Contoso.Extensions;

using System.Performance; // guessed; never verified against the source file

codeunit 50100 "Tooling Extension"
{
    procedure Run()
    var
        ToolingPage: Page "Some Tooling Page"; // resolves in a local build, fails in VS Code
    begin
        ToolingPage.Run();
    end;
}
