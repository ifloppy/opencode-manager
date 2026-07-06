unit oc_profiles;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, oc_paths;

type
  TProfileManager = class
  private
    FRootDir: string;
  public
    constructor Create(const ARootDir: string = '');
    function Profiles: TStringList;
    function ProfileDir(const Name: string): string;
    procedure CreateProfile(const Name: string; const SourceConfigDir: string = '');
    procedure DeleteProfile(const Name: string);
    property RootDir: string read FRootDir;
  end;

implementation

procedure CopyFileSimple(const SourceName, TargetName: string);
var
  SourceStream, TargetStream: TFileStream;
begin
  SourceStream := TFileStream.Create(SourceName, fmOpenRead or fmShareDenyWrite);
  try
    TargetStream := TFileStream.Create(TargetName, fmCreate);
    try
      TargetStream.CopyFrom(SourceStream, 0);
    finally
      TargetStream.Free;
    end;
  finally
    SourceStream.Free;
  end;
end;

procedure CopyDirTreeSimple(const SourceDir, TargetDir: string);
var
  Info: TSearchRec;
  SourcePath, TargetPath: string;
begin
  EnsureDir(TargetDir);
  if FindFirst(IncludeTrailingPathDelimiter(SourceDir) + '*', faAnyFile, Info) = 0 then
  begin
    repeat
      if (Info.Name = '.') or (Info.Name = '..') then
        Continue;
      SourcePath := IncludeTrailingPathDelimiter(SourceDir) + Info.Name;
      TargetPath := IncludeTrailingPathDelimiter(TargetDir) + Info.Name;
      if (Info.Attr and faDirectory) <> 0 then
        CopyDirTreeSimple(SourcePath, TargetPath)
      else
        CopyFileSimple(SourcePath, TargetPath);
    until FindNext(Info) <> 0;
    FindClose(Info);
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

constructor TProfileManager.Create(const ARootDir: string);
begin
  inherited Create;
  if ARootDir = '' then
    FRootDir := GetProfilesRootDir
  else
    FRootDir := ARootDir;
  EnsureDir(FRootDir);
end;

function TProfileManager.Profiles: TStringList;
var
  Info: TSearchRec;
begin
  Result := TStringList.Create;
  Result.Sorted := True;
  if FindFirst(IncludeTrailingPathDelimiter(FRootDir) + '*', faDirectory, Info) = 0 then
  begin
    repeat
      if ((Info.Attr and faDirectory) <> 0) and (Info.Name <> '.') and (Info.Name <> '..') then
        Result.Add(Info.Name);
    until FindNext(Info) <> 0;
    FindClose(Info);
  end;
end;

function TProfileManager.ProfileDir(const Name: string): string;
begin
  Result := IncludeTrailingPathDelimiter(FRootDir) + Name;
end;

procedure TProfileManager.CreateProfile(const Name: string; const SourceConfigDir: string);
var
  Target: string;
begin
  if Trim(Name) = '' then
    raise Exception.Create('Profile 名称不能为空');
  Target := ProfileDir(Name);
  EnsureDir(Target);
  if (SourceConfigDir <> '') and DirectoryExists(SourceConfigDir) then
    CopyDirTreeSimple(SourceConfigDir, Target);
end;

procedure TProfileManager.DeleteProfile(const Name: string);
var
  Target: string;
begin
  Target := ProfileDir(Name);
  if DirectoryExists(Target) then
    DeleteDirTreeSimple(Target);
end;

end.
