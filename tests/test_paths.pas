unit test_paths;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, oc_paths;

type
  TPathTests = class(TTestCase)
  private
    FTempDir: string;
    FHomeDir: string;
    FAppDataDir: string;
    FOpenCodeConfig: string;
    FOpenCodeConfigDir: string;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure PrefersExplicitConfigFile;
    procedure PrefersExplicitConfigDirWhenNoConfigFile;
    procedure PrefersJsoncInExplicitConfigDirWhenItExists;
    procedure PrefersHomeJsoncWhenItExists;
    procedure PrefersJsoncOverJsonWhenBothExist;
    procedure PrefersHomeConfigWhenItExists;
    procedure FallsBackToAppDataWhenHomeConfigMissing;
  end;

implementation

var
  CurrentTest: TPathTests = nil;

function PathTestEnv(const Name: string): string;
begin
  Result := '';
  if CurrentTest = nil then
    Exit;
  case Name of
    'USERPROFILE': Result := CurrentTest.FHomeDir;
    'HOME': Result := CurrentTest.FHomeDir;
    'APPDATA': Result := CurrentTest.FAppDataDir;
    'OPENCODE_CONFIG': Result := CurrentTest.FOpenCodeConfig;
    'OPENCODE_CONFIG_DIR': Result := CurrentTest.FOpenCodeConfigDir;
  end;
end;

procedure DeleteDirTreeSimple(const Dir: string);
var
  Info: TSearchRec;
  Path: string;
begin
  if not DirectoryExists(Dir) then
    Exit;
  if FindFirst(IncludeTrailingPathDelimiter(Dir) + '*', faAnyFile, Info) = 0 then
  begin
    repeat
      if (Info.Name = '.') or (Info.Name = '..') then
        Continue;
      Path := IncludeTrailingPathDelimiter(Dir) + Info.Name;
      if (Info.Attr and faDirectory) <> 0 then
        DeleteDirTreeSimple(Path)
      else
        DeleteFile(Path);
    until FindNext(Info) <> 0;
    FindClose(Info);
  end;
  RemoveDir(Dir);
end;

procedure TouchFile(const FileName: string);
var
  Stream: TFileStream;
begin
  ForceDirectories(ExtractFileDir(FileName));
  Stream := TFileStream.Create(FileName, fmCreate);
  try
  finally
    Stream.Free;
  end;
end;

procedure TPathTests.SetUp;
begin
  FTempDir := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'opencode-manager-paths-' + IntToStr(Random(100000));
  FHomeDir := IncludeTrailingPathDelimiter(FTempDir) + 'home';
  FAppDataDir := IncludeTrailingPathDelimiter(FTempDir) + 'appdata';
  FOpenCodeConfig := '';
  FOpenCodeConfigDir := '';
  ForceDirectories(FHomeDir);
  ForceDirectories(FAppDataDir);
  CurrentTest := Self;
  SetEnvironmentReader(@PathTestEnv);
end;

procedure TPathTests.TearDown;
begin
  SetEnvironmentReader(nil);
  CurrentTest := nil;
  DeleteDirTreeSimple(FTempDir);
end;

procedure TPathTests.PrefersExplicitConfigFile;
var
  Expected: string;
begin
  Expected := IncludeTrailingPathDelimiter(FTempDir) + 'custom' + DirectorySeparator + 'opencode.json';
  FOpenCodeConfig := Expected;
  FOpenCodeConfigDir := IncludeTrailingPathDelimiter(FTempDir) + 'ignored';
  AssertEquals(ExpandFileName(Expected), GetOpenCodeConfigFile);
  AssertEquals(ExpandFileName(ExtractFileDir(Expected)), GetOpenCodeConfigDir);
end;

procedure TPathTests.PrefersExplicitConfigDirWhenNoConfigFile;
var
  ExpectedDir: string;
begin
  ExpectedDir := IncludeTrailingPathDelimiter(FTempDir) + 'explicit-dir';
  FOpenCodeConfigDir := ExpectedDir;
  AssertEquals(ExpandFileName(ExpectedDir), GetOpenCodeConfigDir);
  AssertEquals(ExpandFileName(IncludeTrailingPathDelimiter(ExpectedDir) + 'opencode.jsonc'), GetOpenCodeConfigFile);
end;

procedure TPathTests.PrefersJsoncInExplicitConfigDirWhenItExists;
var
  ExpectedDir: string;
begin
  ExpectedDir := IncludeTrailingPathDelimiter(FTempDir) + 'explicit-dir';
  FOpenCodeConfigDir := ExpectedDir;
  TouchFile(IncludeTrailingPathDelimiter(ExpectedDir) + 'opencode.jsonc');
  AssertEquals(ExpandFileName(IncludeTrailingPathDelimiter(ExpectedDir) + 'opencode.jsonc'), GetOpenCodeConfigFile);
end;

procedure TPathTests.PrefersHomeJsoncWhenItExists;
var
  ExpectedDir: string;
begin
  ExpectedDir := IncludeTrailingPathDelimiter(FHomeDir) + '.config' + DirectorySeparator + 'opencode';
  TouchFile(IncludeTrailingPathDelimiter(ExpectedDir) + 'opencode.jsonc');
  AssertEquals(ExpandFileName(ExpectedDir), GetOpenCodeConfigDir);
  AssertEquals(ExpandFileName(IncludeTrailingPathDelimiter(ExpectedDir) + 'opencode.jsonc'), GetOpenCodeConfigFile);
end;

procedure TPathTests.PrefersJsoncOverJsonWhenBothExist;
var
  ExpectedDir: string;
begin
  ExpectedDir := IncludeTrailingPathDelimiter(FHomeDir) + '.config' + DirectorySeparator + 'opencode';
  TouchFile(IncludeTrailingPathDelimiter(ExpectedDir) + 'opencode.json');
  TouchFile(IncludeTrailingPathDelimiter(ExpectedDir) + 'opencode.jsonc');
  AssertEquals(ExpandFileName(IncludeTrailingPathDelimiter(ExpectedDir) + 'opencode.jsonc'), GetOpenCodeConfigFile);
end;

procedure TPathTests.PrefersHomeConfigWhenItExists;
var
  ExpectedDir: string;
begin
  ExpectedDir := IncludeTrailingPathDelimiter(FHomeDir) + '.config' + DirectorySeparator + 'opencode';
  TouchFile(IncludeTrailingPathDelimiter(ExpectedDir) + 'opencode.json');
  AssertEquals(ExpandFileName(ExpectedDir), GetOpenCodeConfigDir);
  AssertEquals(ExpandFileName(IncludeTrailingPathDelimiter(ExpectedDir) + 'opencode.json'), GetOpenCodeConfigFile);
end;

procedure TPathTests.FallsBackToAppDataWhenHomeConfigMissing;
var
  ExpectedDir: string;
begin
  ExpectedDir := IncludeTrailingPathDelimiter(FAppDataDir) + 'opencode';
  AssertEquals(ExpandFileName(ExpectedDir), GetOpenCodeConfigDir);
  AssertEquals(ExpandFileName(IncludeTrailingPathDelimiter(ExpectedDir) + 'opencode.jsonc'), GetOpenCodeConfigFile);
end;

initialization
  RegisterTest(TPathTests);
end.
