unit oc_sessions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson;

type
  TTokenUsage = record
    InputTokens: Int64;
    OutputTokens: Int64;
    TotalTokens: Int64;
  end;

  TModelTokenUsage = record
    ModelName: string;
    Usage: TTokenUsage;
  end;

  TSessionUsage = record
    ProjectName: string;
    SessionName: string;
    FileName: string;
    Usage: TTokenUsage;
  end;

  TModelTokenUsageArray = array of TModelTokenUsage;
  TSessionUsageArray = array of TSessionUsage;

  TSessionUsageSummary = record
    RootDir: string;
    ProjectCount: Integer;
    SessionCount: Integer;
    Total: TTokenUsage;
    Models: TModelTokenUsageArray;
    Sessions: TSessionUsageArray;
  end;

function DiscoverOpenCodeSessionsDir(const ConfigDir: string): string;
function ScanOpenCodeSessions(const RootDir: string): TSessionUsageSummary;
procedure ParseSessionText(const ProjectName, SessionName, FileName, Text: string; var Summary: TSessionUsageSummary);

implementation

uses
  jsonparser, oc_paths;

procedure AddUsage(var Target: TTokenUsage; const Usage: TTokenUsage);
begin
  Inc(Target.InputTokens, Usage.InputTokens);
  Inc(Target.OutputTokens, Usage.OutputTokens);
  Inc(Target.TotalTokens, Usage.TotalTokens);
end;

function ReadInt64Field(Obj: TJSONObject; const Names: array of string): Int64;
var
  I: Integer;
  Data: TJSONData;
begin
  Result := 0;
  if not Assigned(Obj) then
    Exit;
  for I := Low(Names) to High(Names) do
  begin
    Data := Obj.Find(Names[I]);
    if Assigned(Data) and (Data.JSONType in [jtNumber, jtString]) then
      Exit(StrToInt64Def(Data.AsString, 0));
  end;
end;

function ExtractUsage(Obj: TJSONObject): TTokenUsage;
var
  UsageObj, TokensObj: TJSONObject;
  Data: TJSONData;
begin
  Result.InputTokens := 0;
  Result.OutputTokens := 0;
  Result.TotalTokens := 0;
  if not Assigned(Obj) then
    Exit;

  UsageObj := Obj;
  Data := Obj.Find('usage');
  if Data is TJSONObject then
    UsageObj := TJSONObject(Data);

  Result.InputTokens := ReadInt64Field(UsageObj, ['input_tokens', 'inputTokens', 'prompt_tokens', 'promptTokens', 'input', 'prompt']);
  Result.OutputTokens := ReadInt64Field(UsageObj, ['output_tokens', 'outputTokens', 'completion_tokens', 'completionTokens', 'output', 'completion']);
  Result.TotalTokens := ReadInt64Field(UsageObj, ['total_tokens', 'totalTokens', 'total']);

  Data := UsageObj.Find('tokens');
  if Data is TJSONObject then
  begin
    TokensObj := TJSONObject(Data);
    if Result.InputTokens = 0 then
      Result.InputTokens := ReadInt64Field(TokensObj, ['input', 'prompt', 'input_tokens', 'prompt_tokens']);
    if Result.OutputTokens = 0 then
      Result.OutputTokens := ReadInt64Field(TokensObj, ['output', 'completion', 'output_tokens', 'completion_tokens']);
    if Result.TotalTokens = 0 then
      Result.TotalTokens := ReadInt64Field(TokensObj, ['total', 'total_tokens']);
  end;

  if Result.TotalTokens = 0 then
    Result.TotalTokens := Result.InputTokens + Result.OutputTokens;
end;

function FindModelName(Obj: TJSONObject; const CurrentModel: string): string;
var
  Data: TJSONData;
begin
  Result := CurrentModel;
  if not Assigned(Obj) then
    Exit;
  Data := Obj.Find('model');
  if Assigned(Data) and (Data.JSONType = jtString) and (Data.AsString <> '') then
    Result := Data.AsString;
  Data := Obj.Find('modelID');
  if Assigned(Data) and (Data.JSONType = jtString) and (Data.AsString <> '') then
    Result := Data.AsString;
  Data := Obj.Find('model_id');
  if Assigned(Data) and (Data.JSONType = jtString) and (Data.AsString <> '') then
    Result := Data.AsString;
end;

procedure AddModelUsage(var Summary: TSessionUsageSummary; const ModelName: string; const Usage: TTokenUsage);
var
  I, N: Integer;
  Name: string;
begin
  if Usage.TotalTokens = 0 then
    Exit;
  Name := ModelName;
  if Name = '' then
    Name := '未知模型';
  for I := 0 to High(Summary.Models) do
    if Summary.Models[I].ModelName = Name then
    begin
      AddUsage(Summary.Models[I].Usage, Usage);
      Exit;
    end;
  N := Length(Summary.Models);
  SetLength(Summary.Models, N + 1);
  Summary.Models[N].ModelName := Name;
  Summary.Models[N].Usage := Usage;
end;

procedure AddSessionUsage(var Summary: TSessionUsageSummary; const ProjectName, SessionName, FileName: string; const Usage: TTokenUsage);
var
  N: Integer;
begin
  if Usage.TotalTokens = 0 then
    Exit;
  N := Length(Summary.Sessions);
  SetLength(Summary.Sessions, N + 1);
  Summary.Sessions[N].ProjectName := ProjectName;
  Summary.Sessions[N].SessionName := SessionName;
  Summary.Sessions[N].FileName := FileName;
  Summary.Sessions[N].Usage := Usage;
end;

procedure VisitJson(Data: TJSONData; const CurrentModel: string; var Summary: TSessionUsageSummary; var SessionUsage: TTokenUsage);
var
  Obj: TJSONObject;
  Arr: TJSONArray;
  I: Integer;
  ModelName: string;
  Usage: TTokenUsage;
begin
  if Data is TJSONObject then
  begin
    Obj := TJSONObject(Data);
    ModelName := FindModelName(Obj, CurrentModel);
    Usage := ExtractUsage(Obj);
    if Usage.TotalTokens > 0 then
    begin
      AddUsage(Summary.Total, Usage);
      AddUsage(SessionUsage, Usage);
      AddModelUsage(Summary, ModelName, Usage);
    end;
    for I := 0 to Obj.Count - 1 do
      if (Obj.Names[I] <> 'usage') and (Obj.Names[I] <> 'tokens') then
        VisitJson(Obj.Items[I], ModelName, Summary, SessionUsage);
  end
  else if Data is TJSONArray then
  begin
    Arr := TJSONArray(Data);
    for I := 0 to Arr.Count - 1 do
      VisitJson(Arr.Items[I], CurrentModel, Summary, SessionUsage);
  end;
end;

procedure ParseJsonChunk(const ProjectName, SessionName, FileName, Text: string; var Summary: TSessionUsageSummary; var SessionUsage: TTokenUsage);
var
  Data: TJSONData;
begin
  if Trim(Text) = '' then
    Exit;
  try
    Data := GetJSON(Text);
    try
      VisitJson(Data, '', Summary, SessionUsage);
    finally
      Data.Free;
    end;
  except
    // Ignore non-JSON log lines; session exports are not guaranteed to be uniform.
  end;
end;

procedure ParseSessionText(const ProjectName, SessionName, FileName, Text: string; var Summary: TSessionUsageSummary);
var
  Lines: TStringList;
  I: Integer;
  SessionUsage: TTokenUsage;
  ParsedWhole: Boolean;
begin
  SessionUsage.InputTokens := 0;
  SessionUsage.OutputTokens := 0;
  SessionUsage.TotalTokens := 0;
  ParsedWhole := False;
  if (LowerCase(ExtractFileExt(FileName)) <> '.jsonl') and (LowerCase(ExtractFileExt(FileName)) <> '.ndjson') then
  begin
    try
      ParseJsonChunk(ProjectName, SessionName, FileName, Text, Summary, SessionUsage);
      ParsedWhole := SessionUsage.TotalTokens > 0;
    except
      ParsedWhole := False;
    end;
  end;
  if (not ParsedWhole) and (Pos(#10, Text) > 0) then
  begin
    Lines := TStringList.Create;
    try
      Lines.Text := Text;
      for I := 0 to Lines.Count - 1 do
        ParseJsonChunk(ProjectName, SessionName, FileName, Lines[I], Summary, SessionUsage);
    finally
      Lines.Free;
    end;
  end;
  AddSessionUsage(Summary, ProjectName, SessionName, FileName, SessionUsage);
end;

function DiscoverOpenCodeSessionsDir(const ConfigDir: string): string;
var
  Home, Candidate: string;
begin
  Result := '';
  Candidate := IncludeTrailingPathDelimiter(ConfigDir) + 'sessions';
  if DirectoryExists(Candidate) then
    Exit(Candidate);
  Candidate := IncludeTrailingPathDelimiter(ConfigDir) + 'history';
  if DirectoryExists(Candidate) then
    Exit(Candidate);
  Home := GetUserHomeDirSafe;
  Candidate := IncludeTrailingPathDelimiter(Home) + '.local' + DirectorySeparator + 'share' + DirectorySeparator + 'opencode' + DirectorySeparator + 'sessions';
  if DirectoryExists(Candidate) then
    Exit(Candidate);
  Candidate := IncludeTrailingPathDelimiter(Home) + '.opencode' + DirectorySeparator + 'sessions';
  if DirectoryExists(Candidate) then
    Exit(Candidate);
  Result := IncludeTrailingPathDelimiter(ConfigDir) + 'sessions';
end;

procedure ScanDir(const RootDir, Dir: string; var Summary: TSessionUsageSummary; Projects: TStringList);
var
  Search: TSearchRec;
  Path, Ext, Rel, ProjectName, Text: string;
  Stream: TStringStream;
begin
  if FindFirst(IncludeTrailingPathDelimiter(Dir) + '*', faAnyFile, Search) <> 0 then
    Exit;
  try
    repeat
      if (Search.Name = '.') or (Search.Name = '..') then
        Continue;
      Path := IncludeTrailingPathDelimiter(Dir) + Search.Name;
      if (Search.Attr and faDirectory) <> 0 then
        ScanDir(RootDir, Path, Summary, Projects)
      else
      begin
        Ext := LowerCase(ExtractFileExt(Search.Name));
        if (Ext <> '.json') and (Ext <> '.jsonl') and (Ext <> '.ndjson') then
          Continue;
        Rel := Copy(ExtractFileDir(Path), Length(IncludeTrailingPathDelimiter(RootDir)) + 1, MaxInt);
        ProjectName := Rel;
        if Pos(DirectorySeparator, ProjectName) > 0 then
          ProjectName := Copy(ProjectName, 1, Pos(DirectorySeparator, ProjectName) - 1);
        if ProjectName = '' then
          ProjectName := '默认项目';
        if Projects.IndexOf(ProjectName) < 0 then
          Projects.Add(ProjectName);
        Stream := TStringStream.Create('', TEncoding.UTF8);
        try
          Stream.LoadFromFile(Path);
          Text := Stream.DataString;
        finally
          Stream.Free;
        end;
        ParseSessionText(ProjectName, ChangeFileExt(Search.Name, ''), Path, Text, Summary);
      end;
    until FindNext(Search) <> 0;
  finally
    FindClose(Search);
  end;
end;

function ScanOpenCodeSessions(const RootDir: string): TSessionUsageSummary;
var
  Projects: TStringList;
begin
  Result.RootDir := RootDir;
  Result.ProjectCount := 0;
  Result.SessionCount := 0;
  Result.Total.InputTokens := 0;
  Result.Total.OutputTokens := 0;
  Result.Total.TotalTokens := 0;
  SetLength(Result.Models, 0);
  SetLength(Result.Sessions, 0);
  if (RootDir = '') or (not DirectoryExists(RootDir)) then
    Exit;
  Projects := TStringList.Create;
  try
    Projects.Sorted := True;
    Projects.Duplicates := dupIgnore;
    ScanDir(RootDir, RootDir, Result, Projects);
    Result.ProjectCount := Projects.Count;
    Result.SessionCount := Length(Result.Sessions);
  finally
    Projects.Free;
  end;
end;

end.
