program test_runner;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, consoletestrunner, test_json, test_config, test_paths, test_profiles, test_presets,
  test_sessions, test_http;

type
  TOpenCodeManagerTestRunner = class(TTestRunner)
  end;

var
  App: TOpenCodeManagerTestRunner;

begin
  Randomize;
  App := TOpenCodeManagerTestRunner.Create(nil);
  try
    App.Initialize;
    App.Run;
  finally
    App.Free;
  end;
end.
