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

implementation

function IncludeTrailingPathDelimiterSafe(const Path: string): string;
begin
  if Path = '' then
    Result := ''
  else
    Result := IncludeTrailingPathDelimiter(Path);
end;

function GetUserHomeDirSafe: string;
begin
  Result := GetEnvironmentVariable('USERPROFILE');
  if Result = '' then
    Result := GetEnvironmentVariable('HOME');
  if Result = '' then
    Result := GetCurrentDir;
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
  AppData := GetEnvironmentVariable('APPDATA');
  if AppData <> '' then
    Result := IncludeTrailingPathDelimiter(AppData) + 'opencode'
  else
    Result := IncludeTrailingPathDelimiter(GetUserHomeDirSafe) + '.config' + DirectorySeparator + 'opencode';
end;

function GetOpenCodeConfigDir: string;
begin
  Result := GetEnvironmentVariable('OPENCODE_CONFIG_DIR');
  if Result = '' then
    Result := ExtractFileDir(GetEnvironmentVariable('OPENCODE_CONFIG'));
  if Result = '' then
    Result := DefaultConfigDir;
  Result := ExpandFileName(ExpandHomePath(Result));
end;

function GetOpenCodeConfigFile: string;
begin
  Result := GetEnvironmentVariable('OPENCODE_CONFIG');
  if Result = '' then
    Result := IncludeTrailingPathDelimiter(GetOpenCodeConfigDir) + 'opencode.json'
  else
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
