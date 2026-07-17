unit fpc_jsonc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser;

function StripJsonComments(const Text: string): string;
function StripTrailingCommas(const Text: string): string;
function NormalizeJsonC(const Text: string): string;
function ParseJsonObject(const Text: string): TJSONObject;
function JsonFormat(Data: TJSONData): string;
function EnsureObject(Parent: TJSONObject; const Name: string): TJSONObject;
function EnsureArray(Parent: TJSONObject; const Name: string): TJSONArray;
function CloneJson(Data: TJSONData): TJSONData;
function FileLooksLikeJsonc(const FileName: string): Boolean;
function TextContainsJsonComments(const Text: string): Boolean;
procedure AtomicWriteTextFile(const Target, Content: string; CreateBackup: Boolean = True);

implementation

function StripJsonComments(const Text: string): string;
var
  I: Integer;
  InString, EscapeNext, InLineComment, InBlockComment: Boolean;
  C, N: Char;
begin
  Result := '';
  InString := False;
  EscapeNext := False;
  InLineComment := False;
  InBlockComment := False;
  I := 1;
  while I <= Length(Text) do
  begin
    C := Text[I];
    if I < Length(Text) then
      N := Text[I + 1]
    else
      N := #0;

    if InLineComment then
    begin
      if C in [#10, #13] then
      begin
        InLineComment := False;
        Result := Result + C;
      end;
      Inc(I);
      Continue;
    end;

    if InBlockComment then
    begin
      if (C = '*') and (N = '/') then
      begin
        InBlockComment := False;
        Inc(I, 2);
      end
      else
      begin
        if C in [#10, #13] then
          Result := Result + C;
        Inc(I);
      end;
      Continue;
    end;

    if InString then
    begin
      Result := Result + C;
      if EscapeNext then
        EscapeNext := False
      else if C = '\' then
        EscapeNext := True
      else if C = '"' then
        InString := False;
      Inc(I);
      Continue;
    end;

    if C = '"' then
    begin
      InString := True;
      Result := Result + C;
      Inc(I);
      Continue;
    end;

    if (C = '/') and (N = '/') then
    begin
      InLineComment := True;
      Inc(I, 2);
      Continue;
    end;

    if (C = '/') and (N = '*') then
    begin
      InBlockComment := True;
      Inc(I, 2);
      Continue;
    end;

    Result := Result + C;
    Inc(I);
  end;
end;

function StripTrailingCommas(const Text: string): string;
var
  I, J: Integer;
  InString, EscapeNext: Boolean;
  C: Char;
begin
  Result := '';
  InString := False;
  EscapeNext := False;
  I := 1;
  while I <= Length(Text) do
  begin
    C := Text[I];
    if InString then
    begin
      Result := Result + C;
      if EscapeNext then
        EscapeNext := False
      else if C = '\' then
        EscapeNext := True
      else if C = '"' then
        InString := False;
      Inc(I);
      Continue;
    end;

    if C = '"' then
    begin
      InString := True;
      Result := Result + C;
      Inc(I);
      Continue;
    end;

    if C = ',' then
    begin
      J := I + 1;
      while (J <= Length(Text)) and (Text[J] in [' ', #9, #10, #13]) do
        Inc(J);
      if (J <= Length(Text)) and (Text[J] in ['}', ']']) then
      begin
        Inc(I);
        Continue;
      end;
    end;

    Result := Result + C;
    Inc(I);
  end;
end;

function NormalizeJsonC(const Text: string): string;
begin
  Result := StripTrailingCommas(StripJsonComments(Text));
end;

function ParseJsonObject(const Text: string): TJSONObject;
var
  Data: TJSONData;
begin
  if Trim(Text) = '' then
    Exit(TJSONObject.Create);
  Data := GetJSON(NormalizeJsonC(Text));
  if not (Data is TJSONObject) then
  begin
    Data.Free;
    raise EJSONParser.Create('Root node must be a JSON object');
  end;
  Result := TJSONObject(Data);
end;

function JsonFormat(Data: TJSONData): string;
begin
  if Assigned(Data) then
    Result := Data.FormatJSON([], 2)
  else
    Result := '{}';
end;

function EnsureObject(Parent: TJSONObject; const Name: string): TJSONObject;
var
  Data: TJSONData;
begin
  Data := Parent.Find(Name);
  if Data is TJSONObject then
    Exit(TJSONObject(Data));
  if Assigned(Data) then
    Parent.Delete(Name);
  Result := TJSONObject.Create;
  Parent.Add(Name, Result);
end;

function EnsureArray(Parent: TJSONObject; const Name: string): TJSONArray;
var
  Data: TJSONData;
begin
  Data := Parent.Find(Name);
  if Data is TJSONArray then
    Exit(TJSONArray(Data));
  if Assigned(Data) then
    Parent.Delete(Name);
  Result := TJSONArray.Create;
  Parent.Add(Name, Result);
end;

function CloneJson(Data: TJSONData): TJSONData;
begin
  if Assigned(Data) then
    Result := GetJSON(Data.AsJSON)
  else
    Result := nil;
end;

function FileLooksLikeJsonc(const FileName: string): Boolean;
begin
  Result := SameText(ExtractFileExt(FileName), '.jsonc');
end;

function TextContainsJsonComments(const Text: string): Boolean;
var
  Normalized: string;
begin
  Normalized := StripJsonComments(Text);
  Result := Length(Normalized) < Length(Text);
end;

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

procedure AtomicWriteTextFile(const Target, Content: string; CreateBackup: Boolean);
var
  Dir, BackupDir, BackupName, TempName: string;
  Stream: TStringStream;
begin
  if Target = '' then
    raise Exception.Create('Target path is empty');
  Dir := ExtractFileDir(Target);
  if (Dir <> '') and (not DirectoryExists(Dir)) then
    ForceDirectories(Dir);

  TempName := Target + '.tmp';
  Stream := TStringStream.Create(Content, TEncoding.UTF8);
  try
    Stream.SaveToFile(TempName);
  finally
    Stream.Free;
  end;

  if not FileExists(TempName) then
    raise Exception.Create('Failed to write temporary file: ' + TempName);

  if CreateBackup and FileExists(Target) then
  begin
    BackupDir := IncludeTrailingPathDelimiter(Dir) + 'backups';
    ForceDirectories(BackupDir);
    BackupName := IncludeTrailingPathDelimiter(BackupDir) + ExtractFileName(Target) + '.' +
      FormatDateTime('yyyymmddhhnnss', Now) + '.bak';
    CopyFileSimple(Target, BackupName);
  end;

  if FileExists(Target) then
  begin
    if not DeleteFile(Target) then
      raise Exception.Create('Failed to replace existing file: ' + Target);
  end;
  if not RenameFile(TempName, Target) then
  begin
    if FileExists(TempName) then
      raise Exception.Create('Failed to finalize save (temp remains): ' + TempName)
    else
      raise Exception.Create('Failed to finalize save: ' + Target);
  end;
end;

end.
