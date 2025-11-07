unit GlobalFunctions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms;

procedure delay(msecs:dword);

implementation

{-------------------------------------------------------------------------}
procedure delay(msecs:dword);
  var
    FirstTickCount:Dword;
  begin
    FirstTickCount:=GetTickCount64;
    repeat
      Application.ProcessMessages; {allowing access to other
                                      controls, etc.}
    until ((GetTickCount64-FirstTickCount) >= msecs);
  end;

{-----------------------------------------------------------------------}

end.

