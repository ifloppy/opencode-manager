unit oc_sessions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson;

type
  TTokenUsage = record
    InputTokens: Int64;
    OutputTokens: Int64;
    ReasoningTokens: Int64;
    CacheReadTokens: Int64;
    CacheWriteTokens: Int64;
    TotalTokens: Int64;
    Cost: Double;
  end;

  TModelTokenUsage = record
    ModelName: string;
    Usage: TTokenUsage;
  end;

  TSessionUsage = record
    SessionId: string;
    ProjectName: string;
    ProjectPath: string;
    SessionName: string;
    FileName: string;
    ModelName: string;
    AgentName: string;
    CreatedTime: Int64;
    UpdatedTime: Int64;
    Usage: TTokenUsage;
  end;

  TProjectSessionUsage = record
    ProjectName: string;
    ProjectPath: string;
    SessionCount: Integer;
    Usage: TTokenUsage;
  end;

  TModelTokenUsageArray = array of TModelTokenUsage;
  TSessionUsageArray = array of TSessionUsage;
  TProjectSessionUsageArray = array of TProjectSessionUsage;

  TSessionUsageSummary = record
    RootDir: string;
    ProjectCount: Integer;
    SessionCount: Integer;
    Total: TTokenUsage;
    Projects: TProjectSessionUsageArray;
    Models: TModelTokenUsageArray;
    Sessions: TSessionUsageArray;
  end;

function DiscoverOpenCodeDatabasePath: string;
function DiscoverOpenCodeSessionsDir(const ConfigDir: string): string;
function ScanOpenCodeDatabase(const DbPath: string): TSessionUsageSummary;
function ScanOpenCodeSessions(const RootDir: string): TSessionUsageSummary;
function NormalizeModelName(const RawModel: string): string;
procedure ParseSessionText(const ProjectName, SessionName, FileName, Text: string; var Summary: TSessionUsageSummary);

implementation

uses
  jsonparser, sqlite3conn, sqldb, oc_paths;

procedure AddUsage(var Target: TTokenUsage; const Usage: TTokenUsage);
begin
  Inc(Target.InputTokens, Usage.InputTokens);
  Inc(Target.OutputTokens, Usage.OutputTokens);
  Inc(Target.ReasoningTokens, Usage.ReasoningTokens);
  Inc(Target.CacheReadTokens, Usage.CacheReadTokens);
  Inc(Target.CacheWriteTokens, Usage.CacheWriteTokens);
  Inc(Target.TotalTokens, Usage.TotalTokens);
  Target.Cost := Target.Cost + Usage.Cost;
end;

procedure ClearUsage(var Usage: TTokenUsage);
begin
  Usage.InputTokens := 0;
  Usage.OutputTokens := 0;
  Usage.ReasoningTokens := 0;
  Usage.CacheReadTokens := 0;
  Usage.CacheWriteTokens := 0;
  Usage.TotalTokens := 0;
  Usage.Cost := 0;
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
  Result.ReasoningTokens := 0;
  Result.CacheReadTokens := 0;
  Result.CacheWriteTokens := 0;
  Result.TotalTokens := 0;
  Result.Cost := 0;
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
    Result.TotalTokens := Result.InputTokens + Result.OutputTokens + Result.ReasoningTokens +
      Result.CacheReadTokens + Result.CacheWriteTokens;
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

function NormalizeModelName(const RawModel: string): string;
var
  Data: TJSONData;
  Obj: TJSONObject;
  ModelId, ProviderId: string;
begin
  Result := Trim(RawModel);
  if Result = '' then
    Exit('未知模型');
  if (Result[1] <> '{') and (Result[1] <> '[') then
    Exit;
  try
    Data := GetJSON(Result);
    try
      if Data is TJSONObject then
      begin
        Obj := TJSONObject(Data);
        ModelId := Obj.Get('id', '');
        ProviderId := Obj.Get('providerID', '');
        if ProviderId = '' then
          ProviderId := Obj.Get('providerId', '');
        if ProviderId = '' then
          ProviderId := Obj.Get('provider', '');
        if ModelId <> '' then
        begin
          if ProviderId <> '' then
            Result := ProviderId + '/' + ModelId
          else
            Result := ModelId;
        end;
      end;
    finally
      Data.Free;
    end;
  except
    // Keep the raw model string if OpenCode changes this field to a non-JSON format.
  end;
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

procedure AddProjectUsage(var Summary: TSessionUsageSummary; const ProjectName, ProjectPath: string; const Usage: TTokenUsage);
var
  I, N: Integer;
  Name: string;
begin
  Name := ProjectName;
  if Name = '' then
    Name := '默认项目';
  for I := 0 to High(Summary.Projects) do
    if (Summary.Projects[I].ProjectName = Name) and (Summary.Projects[I].ProjectPath = ProjectPath) then
    begin
      Inc(Summary.Projects[I].SessionCount);
      AddUsage(Summary.Projects[I].Usage, Usage);
      Exit;
    end;
  N := Length(Summary.Projects);
  SetLength(Summary.Projects, N + 1);
  Summary.Projects[N].ProjectName := Name;
  Summary.Projects[N].ProjectPath := ProjectPath;
  Summary.Projects[N].SessionCount := 1;
  Summary.Projects[N].Usage := Usage;
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
  Summary.Sessions[N].ProjectPath := '';
  Summary.Sessions[N].SessionName := SessionName;
  Summary.Sessions[N].FileName := FileName;
  Summary.Sessions[N].Usage := Usage;
  AddProjectUsage(Summary, ProjectName, '', Usage);
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
  SessionUsage.ReasoningTokens := 0;
  SessionUsage.CacheReadTokens := 0;
  SessionUsage.CacheWriteTokens := 0;
  SessionUsage.TotalTokens := 0;
  SessionUsage.Cost := 0;
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

function JoinPath(const Parts: array of string): string;
var
  I: Integer;
begin
  Result := '';
  for I := Low(Parts) to High(Parts) do
    if Parts[I] <> '' then
    begin
      if Result = '' then
        Result := Parts[I]
      else
        Result := IncludeTrailingPathDelimiter(Result) + Parts[I];
    end;
end;

function FileHasExpectedOpenCodeTables(const DbPath: string): Boolean;
var
  Conn: TSQLite3Connection;
  Tran: TSQLTransaction;
  Query: TSQLQuery;
  Found: Integer;
begin
  Result := False;
  if not FileExists(DbPath) then
    Exit;
  Conn := TSQLite3Connection.Create(nil);
  Tran := TSQLTransaction.Create(nil);
  Query := TSQLQuery.Create(nil);
  try
    Conn.DatabaseName := DbPath;
    Conn.Transaction := Tran;
    Query.DataBase := Conn;
    Query.Transaction := Tran;
    Conn.Open;
    Tran.StartTransaction;
    Query.SQL.Text := 'SELECT COUNT(*) AS found FROM sqlite_master WHERE type = ''table'' AND name IN (''session'', ''project'')';
    Query.Open;
    Found := Query.FieldByName('found').AsInteger;
    Query.Close;
    Result := Found >= 2;
    Tran.Rollback;
  except
    if Tran.Active then
      Tran.Rollback;
    Result := False;
  end;
  Query.Free;
  Tran.Free;
  Conn.Free;
end;

function DiscoverOpenCodeDatabasePath: string;
var
  Home, Candidate, AppData: string;
begin
  Result := '';
  Home := GetUserHomeDirSafe;
  Candidate := JoinPath([Home, '.local', 'share', 'opencode', 'opencode.db']);
  if FileHasExpectedOpenCodeTables(Candidate) then
    Exit(Candidate);

  AppData := GetEnvironmentVariable('LOCALAPPDATA');
  Candidate := JoinPath([AppData, 'opencode', 'opencode.db']);
  if FileHasExpectedOpenCodeTables(Candidate) then
    Exit(Candidate);

  AppData := GetEnvironmentVariable('APPDATA');
  Candidate := JoinPath([AppData, 'opencode', 'opencode.db']);
  if FileHasExpectedOpenCodeTables(Candidate) then
    Exit(Candidate);

  Candidate := JoinPath([Home, 'Library', 'Application Support', 'opencode', 'opencode.db']);
  if FileHasExpectedOpenCodeTables(Candidate) then
    Exit(Candidate);

  Result := '';
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

procedure AddDatabaseSession(var Summary: TSessionUsageSummary; Query: TSQLQuery);
var
  N: Integer;
  Usage: TTokenUsage;
  ProjectName, ProjectPath, ModelName: string;
begin
  ClearUsage(Usage);
  Usage.InputTokens := Query.FieldByName('tokens_input').AsLargeInt;
  Usage.OutputTokens := Query.FieldByName('tokens_output').AsLargeInt;
  Usage.ReasoningTokens := Query.FieldByName('tokens_reasoning').AsLargeInt;
  Usage.CacheReadTokens := Query.FieldByName('tokens_cache_read').AsLargeInt;
  Usage.CacheWriteTokens := Query.FieldByName('tokens_cache_write').AsLargeInt;
  Usage.TotalTokens := Usage.InputTokens + Usage.OutputTokens + Usage.ReasoningTokens +
    Usage.CacheReadTokens + Usage.CacheWriteTokens;
  Usage.Cost := Query.FieldByName('cost').AsFloat;

  ProjectName := Query.FieldByName('project_name').AsString;
  ProjectPath := Query.FieldByName('project_path').AsString;
  if ProjectName = '' then
  begin
    ProjectName := ExtractFileName(ExcludeTrailingPathDelimiter(ProjectPath));
    if ProjectName = '' then
      ProjectName := '默认项目';
  end;
  ModelName := NormalizeModelName(Query.FieldByName('model').AsString);

  AddUsage(Summary.Total, Usage);
  AddModelUsage(Summary, ModelName, Usage);
  AddProjectUsage(Summary, ProjectName, ProjectPath, Usage);

  N := Length(Summary.Sessions);
  SetLength(Summary.Sessions, N + 1);
  Summary.Sessions[N].SessionId := Query.FieldByName('id').AsString;
  Summary.Sessions[N].ProjectName := ProjectName;
  Summary.Sessions[N].ProjectPath := ProjectPath;
  Summary.Sessions[N].SessionName := Query.FieldByName('title').AsString;
  if Summary.Sessions[N].SessionName = '' then
    Summary.Sessions[N].SessionName := Query.FieldByName('slug').AsString;
  Summary.Sessions[N].FileName := Query.FieldByName('id').AsString;
  Summary.Sessions[N].ModelName := ModelName;
  Summary.Sessions[N].AgentName := Query.FieldByName('agent').AsString;
  Summary.Sessions[N].CreatedTime := Query.FieldByName('time_created').AsLargeInt;
  Summary.Sessions[N].UpdatedTime := Query.FieldByName('time_updated').AsLargeInt;
  Summary.Sessions[N].Usage := Usage;
end;

function ScanOpenCodeDatabase(const DbPath: string): TSessionUsageSummary;
var
  Conn: TSQLite3Connection;
  Tran: TSQLTransaction;
  Query: TSQLQuery;
begin
  Result.RootDir := DbPath;
  Result.ProjectCount := 0;
  Result.SessionCount := 0;
  ClearUsage(Result.Total);
  SetLength(Result.Projects, 0);
  SetLength(Result.Models, 0);
  SetLength(Result.Sessions, 0);
  if (DbPath = '') or (not FileExists(DbPath)) or (not FileHasExpectedOpenCodeTables(DbPath)) then
    Exit;

  Conn := TSQLite3Connection.Create(nil);
  Tran := TSQLTransaction.Create(nil);
  Query := TSQLQuery.Create(nil);
  try
    Conn.DatabaseName := DbPath;
    Conn.Transaction := Tran;
    Query.DataBase := Conn;
    Query.Transaction := Tran;
    Conn.Open;
    Tran.StartTransaction;
    Query.SQL.Text :=
      'SELECT s.id, s.slug, s.title, s.model, s.agent, s.time_created, s.time_updated, ' +
      's.cost, s.tokens_input, s.tokens_output, s.tokens_reasoning, s.tokens_cache_read, s.tokens_cache_write, ' +
      'COALESCE(NULLIF(p.name, ''''), NULLIF(s.directory, '''')) AS project_name, ' +
      'COALESCE(NULLIF(p.worktree, ''''), NULLIF(s.directory, '''')) AS project_path ' +
      'FROM session s LEFT JOIN project p ON s.project_id = p.id ' +
      'ORDER BY s.time_updated DESC, s.time_created DESC';
    Query.Open;
    while not Query.EOF do
    begin
      AddDatabaseSession(Result, Query);
      Query.Next;
    end;
    Query.Close;
    Result.ProjectCount := Length(Result.Projects);
    Result.SessionCount := Length(Result.Sessions);
    Tran.Rollback;
  except
    if Tran.Active then
      Tran.Rollback;
    SetLength(Result.Projects, 0);
    SetLength(Result.Models, 0);
    SetLength(Result.Sessions, 0);
    Result.ProjectCount := 0;
    Result.SessionCount := 0;
    ClearUsage(Result.Total);
  end;
  Query.Free;
  Tran.Free;
  Conn.Free;
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
  SetLength(Result.Projects, 0);
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
