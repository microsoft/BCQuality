// Verified by reading line 1 of the source file for "Some Tooling Page":
// namespace System.Tooling;

namespace Contoso.Extensions;

using System.Tooling;

codeunit 50100 "Tooling Extension"
{
    procedure Run()
    var
        ToolingPage: Page "Some Tooling Page";
    begin
        ToolingPage.Run();
    end;
}
