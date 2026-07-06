program opencode_manager;

{$mode objfpc}{$H+}

{$IFDEF MSWINDOWS}
{$APPTYPE GUI}
{$ENDIF}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces, Forms, mainform;

{$R *.res}

begin
  RequireDerivedFormResource := False;
  Application.Scaled := True;
  Application.ShowHint := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainFormInstance);
  Application.Run;
end.
