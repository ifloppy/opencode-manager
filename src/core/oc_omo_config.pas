unit oc_omo_config;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, oc_json, oc_config;

type
  TOMOConfig = class
  private
    FFileName: string;
    FData: TJSONObject;
    function GetData: TJSONObject;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(const AFileName: string);
    procedure LoadFromString(const Text: string);
    procedure SaveToFile(const AFileName: string = '');
    function AsJson: string;
    procedure EnsureSchema;
    function Validate: TValidationIssueArray;
    function AgentIds: TStringList;
    function CategoryIds: TStringList;
    procedure UpsertAgent(const Id, ModelName, Category, Variant, PromptAppend: string; Temperature: Double; Disabled: Boolean; const Thinking: string = ''; const ReasoningEffort: string = '');
    procedure DeleteAgent(const Id: string);
    procedure UpsertCategory(const Id, ModelName, Description, Variant, PromptAppend: string; Disabled: Boolean; const Thinking: string = ''; const ReasoningEffort: string = '');
    procedure DeleteCategory(const Id: string);
    property FileName: string read FFileName;
    property Data: TJSONObject read GetData;
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

procedure AddIssue(var Issues: TValidationIssueArray; const Severity, Message: string);
var
  N: Integer;
begin
  N := Length(Issues);
  SetLength(Issues, N + 1);
  Issues[N].Severity := Severity;
  Issues[N].Message := Message;
end;

function ObjectKeys(Obj: TJSONObject): TStringList;
var
  I: Integer;
begin
  Result := TStringList.Create;
  Result.Sorted := True;
  if not Assigned(Obj) then
    Exit;
  for I := 0 to Obj.Count - 1 do
    Result.Add(Obj.Names[I]);
end;

constructor TOMOConfig.Create;
begin
  inherited Create;
  FData := TJSONObject.Create;
  EnsureSchema;
end;

destructor TOMOConfig.Destroy;
begin
  FData.Free;
  inherited Destroy;
end;

function TOMOConfig.GetData: TJSONObject;
begin
  Result := FData;
end;

procedure TOMOConfig.LoadFromFile(const AFileName: string);
var
  Stream: TStringStream;
begin
  FFileName := AFileName;
  if not FileExists(AFileName) then
  begin
    FreeAndNil(FData);
    FData := TJSONObject.Create;
    EnsureSchema;
    Exit;
  end;
  Stream := TStringStream.Create('', TEncoding.UTF8);
  try
    Stream.LoadFromFile(AFileName);
    LoadFromString(Stream.DataString);
  finally
    Stream.Free;
  end;
end;

procedure TOMOConfig.LoadFromString(const Text: string);
begin
  FreeAndNil(FData);
  FData := ParseJsonObject(Text);
  EnsureSchema;
end;

procedure TOMOConfig.SaveToFile(const AFileName: string);
var
  Target, Dir, BackupDir, BackupName, TempName: string;
  Stream: TStringStream;
begin
  Target := AFileName;
  if Target = '' then
    Target := FFileName;
  if Target = '' then
    raise Exception.Create('没有 Oh My OpenAgent 配置文件路径');
  Dir := ExtractFileDir(Target);
  if (Dir <> '') and (not DirectoryExists(Dir)) then
    ForceDirectories(Dir);
  if FileExists(Target) then
  begin
    BackupDir := IncludeTrailingPathDelimiter(Dir) + 'backups';
    ForceDirectories(BackupDir);
    BackupName := IncludeTrailingPathDelimiter(BackupDir) + ExtractFileName(Target) + '.' + FormatDateTime('yyyymmddhhnnss', Now) + '.bak';
    CopyFileSimple(Target, BackupName);
  end;
  TempName := Target + '.tmp';
  Stream := TStringStream.Create(AsJson, TEncoding.UTF8);
  try
    Stream.SaveToFile(TempName);
  finally
    Stream.Free;
  end;
  if FileExists(Target) then
    DeleteFile(Target);
  if not RenameFile(TempName, Target) then
    raise Exception.Create('保存配置失败: ' + Target);
  FFileName := Target;
end;

function TOMOConfig.AsJson: string;
begin
  Result := JsonFormat(FData);
end;

procedure TOMOConfig.EnsureSchema;
begin
  if not Assigned(FData.Find('$schema')) then
    FData.Add('$schema', 'https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json');
end;

function TOMOConfig.Validate: TValidationIssueArray;
var
  Node: TJSONData;
begin
  Result := nil;
  SetLength(Result, 0);
  Node := FData.Find('agents');
  if Assigned(Node) and not (Node is TJSONObject) then
    AddIssue(Result, 'error', 'OMO 字段 agents 必须是对象');
  Node := FData.Find('categories');
  if Assigned(Node) and not (Node is TJSONObject) then
    AddIssue(Result, 'error', 'OMO 字段 categories 必须是对象');
  if Length(Result) = 0 then
    AddIssue(Result, 'info', 'Oh My OpenAgent 配置结构检查通过');
end;

function TOMOConfig.AgentIds: TStringList;
begin
  if FData.Find('agents') is TJSONObject then
    Result := ObjectKeys(TJSONObject(FData.Find('agents')))
  else
    Result := ObjectKeys(nil);
end;

function TOMOConfig.CategoryIds: TStringList;
begin
  if FData.Find('categories') is TJSONObject then
    Result := ObjectKeys(TJSONObject(FData.Find('categories')))
  else
    Result := ObjectKeys(nil);
end;

procedure TOMOConfig.UpsertAgent(const Id, ModelName, Category, Variant, PromptAppend: string; Temperature: Double; Disabled: Boolean; const Thinking: string = ''; const ReasoningEffort: string = '');
var
  Agents, Agent, ThinkingObj, ReasoningObj: TJSONObject;
begin
  Agents := EnsureObject(FData, 'agents');
  if Agents.Find(Id) is TJSONObject then
    Agent := TJSONObject(Agents.Find(Id))
  else
  begin
    Agent := TJSONObject.Create;
    Agents.Add(Id, Agent);
  end;
  if ModelName <> '' then
    Agent.Strings['model'] := ModelName;
  if Category <> '' then
    Agent.Strings['category'] := Category;
  if Variant <> '' then
    Agent.Strings['variant'] := Variant;
  if PromptAppend <> '' then
    Agent.Strings['prompt_append'] := PromptAppend;
  Agent.Floats['temperature'] := Temperature;
  Agent.Booleans['disable'] := Disabled;
  if Thinking <> '' then
  begin
    ThinkingObj := EnsureObject(Agent, 'thinking');
    ThinkingObj.Strings['type'] := Thinking;
  end
  else if Assigned(Agent.Find('thinking')) then
    Agent.Delete('thinking');
  if ReasoningEffort <> '' then
  begin
    ReasoningObj := EnsureObject(Agent, 'reasoning');
    ReasoningObj.Strings['effort'] := ReasoningEffort;
  end
  else if Assigned(Agent.Find('reasoning')) then
    Agent.Delete('reasoning');
end;

procedure TOMOConfig.DeleteAgent(const Id: string);
var
  Agents: TJSONObject;
begin
  Agents := EnsureObject(FData, 'agents');
  if Assigned(Agents.Find(Id)) then
    Agents.Delete(Id);
end;

procedure TOMOConfig.UpsertCategory(const Id, ModelName, Description, Variant, PromptAppend: string; Disabled: Boolean; const Thinking: string = ''; const ReasoningEffort: string = '');
var
  Categories, Category, ThinkingObj, ReasoningObj: TJSONObject;
begin
  Categories := EnsureObject(FData, 'categories');
  if Categories.Find(Id) is TJSONObject then
    Category := TJSONObject(Categories.Find(Id))
  else
  begin
    Category := TJSONObject.Create;
    Categories.Add(Id, Category);
  end;
  if ModelName <> '' then
    Category.Strings['model'] := ModelName;
  if Description <> '' then
    Category.Strings['description'] := Description;
  if Variant <> '' then
    Category.Strings['variant'] := Variant;
  if PromptAppend <> '' then
    Category.Strings['prompt_append'] := PromptAppend;
  Category.Booleans['disable'] := Disabled;
  if Thinking <> '' then
  begin
    ThinkingObj := EnsureObject(Category, 'thinking');
    ThinkingObj.Strings['type'] := Thinking;
  end
  else if Assigned(Category.Find('thinking')) then
    Category.Delete('thinking');
  if ReasoningEffort <> '' then
  begin
    ReasoningObj := EnsureObject(Category, 'reasoning');
    ReasoningObj.Strings['effort'] := ReasoningEffort;
  end
  else if Assigned(Category.Find('reasoning')) then
    Category.Delete('reasoning');
end;

procedure TOMOConfig.DeleteCategory(const Id: string);
var
  Categories: TJSONObject;
begin
  Categories := EnsureObject(FData, 'categories');
  if Assigned(Categories.Find(Id)) then
    Categories.Delete(Id);
end;

end.
