unit oc_paths;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function IncludeTrailingPathDelimiterSafe(const Path: string): string;
function ExpandHomePath(const Path: string): string;
function GetUserHomeDirSafe: string;
function GetOpenCodeConfigDir: string;
function GetOpenCodeConfigFile: string;
function GetOpenAgentConfigFile(const ConfigDir: string): string;
function GetProfilesRootDir: string;
procedure EnsureDir(const Dir: string);

type
  TGetEnvFunc = function(const Name: string): string;

procedure SetEnvironmentReader(AReader: TGetEnvFunc);

implementation

var
  EnvironmentReader: TGetEnvFunc = nil;

function ReadEnv(const Name: string): string;
begin
  if Assigned(EnvironmentReader) then
    Result := EnvironmentReader(Name)
  else
    Result := GetEnvironmentVariable(Name);
end;

procedure SetEnvironmentReader(AReader: TGetEnvFunc);
begin
  EnvironmentReader := AReader;
end;

function IncludeTrailingPathDelimiterSafe(const Path: string): string;
begin
  if Path = '' then
    Result := ''
  else
    Result := IncludeTrailingPathDelimiter(Path);
end;

function GetUserHomeDirSafe: string;
begin
  Result := ReadEnv('USERPROFILE');
  if Result = '' then
    Result := ReadEnv('HOME');
  if Result = '' then
    Result := GetCurrentDir;
end;

function HomeConfigDir: string;
begin
  Result := IncludeTrailingPathDelimiter(GetUserHomeDirSafe) + '.config' + DirectorySeparator + 'opencode';
end;

function ExpandHomePath(const Path: string): string;
begin
  if Path = '~' then
    Result := GetUserHomeDirSafe
  else if (Length(Path) > 1) and (Path[1] = '~') and (Path[2] in ['/', '\']) then
    Result := IncludeTrailingPathDelimiter(GetUserHomeDirSafe) + Copy(Path, 3, MaxInt)
  else
    Result := Path;
end;

function DefaultConfigDir: string;
var
  AppData: string;
begin
  Result := HomeConfigDir;
  if FileExists(IncludeTrailingPathDelimiter(Result) + 'opencode.json') or
     FileExists(IncludeTrailingPathDelimiter(Result) + 'opencode.jsonc') then
    Exit;

  AppData := ReadEnv('APPDATA');
  if AppData <> '' then
    Result := IncludeTrailingPathDelimiter(AppData) + 'opencode'
  else
    Result := HomeConfigDir;
end;

function GetOpenCodeConfigDir: string;
begin
  Result := ExtractFileDir(ReadEnv('OPENCODE_CONFIG'));
  if Result = '' then
    Result := ReadEnv('OPENCODE_CONFIG_DIR');
  if Result = '' then
    Result := DefaultConfigDir;
  Result := ExpandFileName(ExpandHomePath(Result));
end;

function ExistingFile(const Dir: string; const Names: array of string): string;
var
  I: Integer;
  Candidate: string;
begin
  for I := Low(Names) to High(Names) do
  begin
    Candidate := IncludeTrailingPathDelimiter(Dir) + Names[I];
    if FileExists(Candidate) then
      Exit(Candidate);
  end;
  Result := IncludeTrailingPathDelimiter(Dir) + Names[0];
end;

function GetOpenCodeConfigFile: string;
begin
  Result := ReadEnv('OPENCODE_CONFIG');
  if Result = '' then
    Result := ExistingFile(GetOpenCodeConfigDir, [
      'opencode.jsonc',
      'opencode.json'
    ])
  else
    Result := ExpandFileName(ExpandHomePath(Result));
end;

function GetOpenAgentConfigFile(const ConfigDir: string): string;
begin
  Result := ExistingFile(ConfigDir, [
    'oh-my-openagent.jsonc',
    'oh-my-openagent.json',
    'oh-my-opencode.jsonc',
    'oh-my-opencode.json'
  ]);
end;

function GetProfilesRootDir: string;
begin
  Result := IncludeTrailingPathDelimiter(GetUserHomeDirSafe) + '.config' + DirectorySeparator + 'opencode-profiles';
  Result := ExpandFileName(Result);
end;

procedure EnsureDir(const Dir: string);
begin
  if (Dir <> '') and (not DirectoryExists(Dir)) then
    ForceDirectories(Dir);
end;

end.
