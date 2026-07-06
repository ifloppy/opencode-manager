unit oc_config;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, oc_json;

type
  TValidationIssue = record
    Severity: string;
    Message: string;
  end;

  TValidationIssueArray = array of TValidationIssue;

  { TOpenCodeConfig }

  TOpenCodeConfig = class
  private
    FFileName: string;
    FData: TJSONObject;
    function GetData: TJSONObject;
    function FindObject(const Section, Name: string): TJSONObject;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(const AFileName: string);
    procedure SaveToFile(const AFileName: string = '');
    procedure LoadFromString(const Text: string);
    function AsJson: string;
    procedure EnsureSchema;
    function Validate: TValidationIssueArray;

    function ProviderIds: TStringList;
    function ModelIds(const ProviderId: string): TStringList;
    function AgentIds: TStringList;
    function McpIds: TStringList;
    function Plugins: TStringList;

    procedure UpsertProvider(const Id, DisplayName, NpmPackage, BaseURL, ApiKey: string);
    procedure DeleteProvider(const Id: string);
    procedure UpsertModel(const ProviderId, ModelId, DisplayName: string);
    procedure DeleteModel(const ProviderId, ModelId: string);
    procedure UpsertAgent(const Id, Description, Mode, Model, Prompt: string; Temperature: Double; Disabled: Boolean);
    procedure DeleteAgent(const Id: string);
    procedure UpsertMcpLocal(const Id, CommandText: string; Enabled: Boolean);
    procedure UpsertMcpRemote(const Id, Url: string; Enabled: Boolean);
    procedure DeleteMcp(const Id: string);
    procedure UpsertPlugin(const PluginName: string);
    procedure DeletePlugin(const PluginName: string);

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

{ TOpenCodeConfig }

constructor TOpenCodeConfig.Create;
begin
  inherited Create;
  FData := TJSONObject.Create;
  EnsureSchema;
end;

destructor TOpenCodeConfig.Destroy;
begin
  FData.Free;
  inherited Destroy;
end;

function TOpenCodeConfig.GetData: TJSONObject;
begin
  Result := FData;
end;

function TOpenCodeConfig.FindObject(const Section, Name: string): TJSONObject;
var
  Root: TJSONObject;
  Node: TJSONData;
begin
  Result := nil;
  Node := FData.Find(Section);
  if not (Node is TJSONObject) then
    Exit;
  Root := TJSONObject(Node);
  Node := Root.Find(Name);
  if Node is TJSONObject then
    Result := TJSONObject(Node);
end;

procedure TOpenCodeConfig.LoadFromFile(const AFileName: string);
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

procedure TOpenCodeConfig.SaveToFile(const AFileName: string);
var
  Target, Dir, BackupDir, BackupName, TempName: string;
  Stream: TStringStream;
begin
  Target := AFileName;
  if Target = '' then
    Target := FFileName;
  if Target = '' then
    raise Exception.Create('没有配置文件路径');
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
  RenameFile(TempName, Target);
  FFileName := Target;
end;

procedure TOpenCodeConfig.LoadFromString(const Text: string);
begin
  FreeAndNil(FData);
  FData := ParseJsonObject(Text);
  EnsureSchema;
end;

function TOpenCodeConfig.AsJson: string;
begin
  Result := JsonFormat(FData);
end;

procedure TOpenCodeConfig.EnsureSchema;
begin
  if not Assigned(FData.Find('$schema')) then
    FData.Add('$schema', 'https://opencode.ai/config.json');
end;

function TOpenCodeConfig.Validate: TValidationIssueArray;
var
  Node: TJSONData;
  I: Integer;
  Agents: TJSONObject;
  Mode: string;
begin
  Result := nil;
  SetLength(Result, 0);
  for I := 0 to 2 do
  begin
    case I of
      0: Node := FData.Find('provider');
      1: Node := FData.Find('agent');
    else
      Node := FData.Find('mcp');
    end;
    if Assigned(Node) and not (Node is TJSONObject) then
      AddIssue(Result, 'error', '字段 provider/agent/mcp 必须是对象');
  end;
  Node := FData.Find('plugin');
  if Assigned(Node) and not (Node is TJSONArray) then
    AddIssue(Result, 'error', '字段 plugin 必须是数组');
  Node := FData.Find('model');
  if Assigned(Node) and (Node.JSONType = jtString) and (Pos('/', Node.AsString) = 0) then
    AddIssue(Result, 'warning', '默认模型建议使用 provider/model 格式');

  Node := FData.Find('agent');
  if Node is TJSONObject then
  begin
    Agents := TJSONObject(Node);
    for I := 0 to Agents.Count - 1 do
      if Agents.Items[I] is TJSONObject then
      begin
        Mode := TJSONObject(Agents.Items[I]).Get('mode', 'all');
        if (Mode <> 'primary') and (Mode <> 'subagent') and (Mode <> 'all') then
          AddIssue(Result, 'error', 'Agent ' + Agents.Names[I] + ' 的 mode 必须是 primary/subagent/all');
      end;
  end;

  if Length(Result) = 0 then
    AddIssue(Result, 'info', '配置结构检查通过');
end;

function TOpenCodeConfig.ProviderIds: TStringList;
begin
  if FData.Find('provider') is TJSONObject then
    Result := ObjectKeys(TJSONObject(FData.Find('provider')))
  else
    Result := ObjectKeys(nil);
end;

function TOpenCodeConfig.ModelIds(const ProviderId: string): TStringList;
var
  Provider, Models: TJSONObject;
begin
  Provider := FindObject('provider', ProviderId);
  if Assigned(Provider) and (Provider.Find('models') is TJSONObject) then
    Models := TJSONObject(Provider.Find('models'))
  else
    Models := nil;
  Result := ObjectKeys(Models);
end;

function TOpenCodeConfig.AgentIds: TStringList;
begin
  if FData.Find('agent') is TJSONObject then
    Result := ObjectKeys(TJSONObject(FData.Find('agent')))
  else
    Result := ObjectKeys(nil);
end;

function TOpenCodeConfig.McpIds: TStringList;
begin
  if FData.Find('mcp') is TJSONObject then
    Result := ObjectKeys(TJSONObject(FData.Find('mcp')))
  else
    Result := ObjectKeys(nil);
end;

function TOpenCodeConfig.Plugins: TStringList;
var
  Arr: TJSONArray;
  Node: TJSONData;
  I: Integer;
begin
  Result := TStringList.Create;
  Result.Sorted := True;
  Node := FData.Find('plugin');
  if not (Node is TJSONArray) then
    Exit;
  Arr := TJSONArray(Node);
  for I := 0 to Arr.Count - 1 do
    Result.Add(Arr.Strings[I]);
end;

procedure TOpenCodeConfig.UpsertProvider(const Id, DisplayName, NpmPackage, BaseURL, ApiKey: string);
var
  Providers, Provider, Options: TJSONObject;
begin
  Providers := EnsureObject(FData, 'provider');
  if Providers.Find(Id) is TJSONObject then
    Provider := TJSONObject(Providers.Find(Id))
  else
  begin
    Provider := TJSONObject.Create;
    Providers.Add(Id, Provider);
  end;
  Provider.Strings['name'] := DisplayName;
  if NpmPackage <> '' then
    Provider.Strings['npm'] := NpmPackage;
  Options := EnsureObject(Provider, 'options');
  if BaseURL <> '' then
    Options.Strings['baseURL'] := BaseURL;
  if ApiKey <> '' then
    Options.Strings['apiKey'] := ApiKey;
  EnsureObject(Provider, 'models');
end;

procedure TOpenCodeConfig.DeleteProvider(const Id: string);
var
  Providers: TJSONObject;
begin
  Providers := EnsureObject(FData, 'provider');
  if Assigned(Providers.Find(Id)) then
    Providers.Delete(Id);
end;

procedure TOpenCodeConfig.UpsertModel(const ProviderId, ModelId, DisplayName: string);
var
  Providers, Provider, Models, ModelObj: TJSONObject;
begin
  Providers := EnsureObject(FData, 'provider');
  if Providers.Find(ProviderId) is TJSONObject then
    Provider := TJSONObject(Providers.Find(ProviderId))
  else
  begin
    Provider := TJSONObject.Create;
    Providers.Add(ProviderId, Provider);
  end;
  Models := EnsureObject(Provider, 'models');
  if Models.Find(ModelId) is TJSONObject then
    ModelObj := TJSONObject(Models.Find(ModelId))
  else
  begin
    ModelObj := TJSONObject.Create;
    Models.Add(ModelId, ModelObj);
  end;
  if DisplayName <> '' then
    ModelObj.Strings['name'] := DisplayName;
end;

procedure TOpenCodeConfig.DeleteModel(const ProviderId, ModelId: string);
var
  Provider, Models: TJSONObject;
begin
  Provider := FindObject('provider', ProviderId);
  if Assigned(Provider) and (Provider.Find('models') is TJSONObject) then
  begin
    Models := TJSONObject(Provider.Find('models'));
    if Assigned(Models.Find(ModelId)) then
      Models.Delete(ModelId);
  end;
end;

procedure TOpenCodeConfig.UpsertAgent(const Id, Description, Mode, Model, Prompt: string; Temperature: Double; Disabled: Boolean);
var
  Agents, Agent: TJSONObject;
begin
  Agents := EnsureObject(FData, 'agent');
  if Agents.Find(Id) is TJSONObject then
    Agent := TJSONObject(Agents.Find(Id))
  else
  begin
    Agent := TJSONObject.Create;
    Agents.Add(Id, Agent);
  end;
  Agent.Strings['description'] := Description;
  Agent.Strings['mode'] := Mode;
  if Model <> '' then
    Agent.Strings['model'] := Model;
  if Prompt <> '' then
    Agent.Strings['prompt'] := Prompt;
  Agent.Floats['temperature'] := Temperature;
  Agent.Booleans['disable'] := Disabled;
end;

procedure TOpenCodeConfig.DeleteAgent(const Id: string);
var
  Agents: TJSONObject;
begin
  Agents := EnsureObject(FData, 'agent');
  if Assigned(Agents.Find(Id)) then
    Agents.Delete(Id);
end;

procedure TOpenCodeConfig.UpsertMcpLocal(const Id, CommandText: string; Enabled: Boolean);
var
  Mcps, Mcp, Env: TJSONObject;
  Arr: TJSONArray;
  Parts: TStringArray;
  Part: string;
begin
  Mcps := EnsureObject(FData, 'mcp');
  if Mcps.Find(Id) is TJSONObject then
    Mcp := TJSONObject(Mcps.Find(Id))
  else
  begin
    Mcp := TJSONObject.Create;
    Mcps.Add(Id, Mcp);
  end;
  Mcp.Strings['type'] := 'local';
  Mcp.Booleans['enabled'] := Enabled;
  if Assigned(Mcp.Find('command')) then
    Mcp.Delete('command');
  Arr := TJSONArray.Create;
  Parts := CommandText.Split([' '], TStringSplitOptions.ExcludeEmpty);
  for Part in Parts do
    Arr.Add(Part);
  Mcp.Add('command', Arr);
  Env := EnsureObject(Mcp, 'environment');
  if Env.Count = 0 then ;
end;

procedure TOpenCodeConfig.UpsertMcpRemote(const Id, Url: string; Enabled: Boolean);
var
  Mcps, Mcp: TJSONObject;
begin
  Mcps := EnsureObject(FData, 'mcp');
  if Mcps.Find(Id) is TJSONObject then
    Mcp := TJSONObject(Mcps.Find(Id))
  else
  begin
    Mcp := TJSONObject.Create;
    Mcps.Add(Id, Mcp);
  end;
  Mcp.Strings['type'] := 'remote';
  Mcp.Strings['url'] := Url;
  Mcp.Booleans['enabled'] := Enabled;
end;

procedure TOpenCodeConfig.DeleteMcp(const Id: string);
var
  Mcps: TJSONObject;
begin
  Mcps := EnsureObject(FData, 'mcp');
  if Assigned(Mcps.Find(Id)) then
    Mcps.Delete(Id);
end;

procedure TOpenCodeConfig.UpsertPlugin(const PluginName: string);
var
  Arr: TJSONArray;
  I: Integer;
begin
  Arr := EnsureArray(FData, 'plugin');
  for I := 0 to Arr.Count - 1 do
    if Arr.Strings[I] = PluginName then
      Exit;
  Arr.Add(PluginName);
end;

procedure TOpenCodeConfig.DeletePlugin(const PluginName: string);
var
  Arr: TJSONArray;
  I: Integer;
begin
  Arr := EnsureArray(FData, 'plugin');
  for I := Arr.Count - 1 downto 0 do
    if Arr.Strings[I] = PluginName then
      Arr.Delete(I);
end;

end.
