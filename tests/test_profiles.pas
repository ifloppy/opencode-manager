unit test_profiles;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, oc_profiles;

type
  TProfileTests = class(TTestCase)
  private
    FTempDir: string;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CreatesAndDeletesProfile;
  end;

implementation

procedure TProfileTests.SetUp;
begin
  FTempDir := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'opencode-manager-tests-' + IntToStr(Random(100000));
  ForceDirectories(FTempDir);
end;

procedure TProfileTests.TearDown;
begin
  if DirectoryExists(FTempDir) then
    RemoveDir(FTempDir);
end;

procedure TProfileTests.CreatesAndDeletesProfile;
var
  Manager: TProfileManager;
  L: TStringList;
begin
  Manager := TProfileManager.Create(FTempDir);
  try
    Manager.CreateProfile('work');
    AssertTrue(DirectoryExists(Manager.ProfileDir('work')));
    L := Manager.Profiles;
    try
      AssertTrue(L.IndexOf('work') >= 0);
    finally
      L.Free;
    end;
    Manager.DeleteProfile('work');
    AssertFalse(DirectoryExists(Manager.ProfileDir('work')));
  finally
    Manager.Free;
  end;
end;

initialization
  RegisterTest(TProfileTests);
end.
