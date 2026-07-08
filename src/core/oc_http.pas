unit oc_http;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TConnectivityResult = record
    Success: Boolean;
    StatusCode: Integer;
    StatusText: string;
    ResponseTimeMs: Integer;
    ErrorMessage: string;
  end;

  TProviderModelInfo = record
    Id: string;
    Name: string;
    Family: string;
    Status: string;
    ContextLimit: Integer;
    InputLimit: Integer;
    OutputLimit: Integer;
    Reasoning: Boolean;
    Attachment: Boolean;
    Temperature: Boolean;
    ToolCall: Boolean;
    Interleaved: string;
    InputModalities: string;
    OutputModalities: string;
  end;

  TProviderModelInfoArray = array of TProviderModelInfo;

function TestModelConnectivity(const ProviderId, BaseURL, ApiKey, ModelId: string): TConnectivityResult;
function FetchProviderModels(const ProviderId, BaseURL, ApiKey: string): TProviderModelInfoArray;
function ParseProviderModels(const ProviderId, ResponseText: string): TProviderModelInfoArray;
procedure ApplyModelsDevCatalog(const ProviderId, ResponseText: string; var Models: TProviderModelInfoArray);

implementation

uses
  fphttpclient, openssl, opensslsockets, fpjson, jsonparser;

const
  DEFAULT_CONTEXT_LIMIT = 200000;
  DEFAULT_OUTPUT_LIMIT = 16000;

function EndsWithTextSimple(const Value, Suffix: string): Boolean;
begin
  Result := (Length(Value) >= Length(Suffix)) and
    (CompareText(Copy(Value, Length(Value) - Length(Suffix) + 1, Length(Suffix)), Suffix) = 0);
end;

function WithTrailingSlash(const Value: string): string;
begin
  Result := Value;
  if (Result <> '') and (Result[Length(Result)] <> '/') then
    Result := Result + '/';
end;

function ModelNameOnly(const ModelId: string): string;
var
  P: Integer;
begin
  P := Pos('/', ModelId);
  if P > 0 then
    Result := Copy(ModelId, P + 1, MaxInt)
  else
    Result := ModelId;
end;

procedure ApplyModelDefaults(var Model: TProviderModelInfo);
begin
  if Model.ContextLimit <= 0 then
    Model.ContextLimit := DEFAULT_CONTEXT_LIMIT;
  if Model.OutputLimit <= 0 then
    Model.OutputLimit := DEFAULT_OUTPUT_LIMIT;
  if Model.InputModalities = '' then
    Model.InputModalities := 'text';
  if Model.OutputModalities = '' then
    Model.OutputModalities := 'text';
end;

function JsonArrayToCsv(Node: TJSONData): string;
var
  Arr: TJSONArray;
  I: Integer;
begin
  Result := '';
  if not (Node is TJSONArray) then
    Exit;
  Arr := TJSONArray(Node);
  for I := 0 to Arr.Count - 1 do
  begin
    if Result <> '' then
      Result := Result + ',';
    Result := Result + Arr.Strings[I];
  end;
end;

procedure AddModel(var Models: TProviderModelInfoArray; const Model: TProviderModelInfo);
var
  N: Integer;
  M: TProviderModelInfo;
begin
  M := Model;
  ApplyModelDefaults(M);
  if M.Id = '' then
    Exit;
  N := Length(Models);
  SetLength(Models, N + 1);
  Models[N] := M;
end;

function FindModelIndex(const Models: TProviderModelInfoArray; const Id: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(Models) do
    if SameText(Models[I].Id, Id) or SameText(ModelNameOnly(Models[I].Id), Id) then
      Exit(I);
end;

procedure ApplyModelObject(var Model: TProviderModelInfo; Obj: TJSONObject);
var
  Limit, Modalities, InterleavedObj: TJSONObject;
  Node: TJSONData;
begin
  if Obj.Get('name', '') <> '' then
    Model.Name := Obj.Get('name', '');
  if Obj.Get('family', '') <> '' then
    Model.Family := Obj.Get('family', '');
  if Obj.Get('status', '') <> '' then
    Model.Status := Obj.Get('status', '');
  Model.Reasoning := Obj.Get('reasoning', Model.Reasoning);
  Model.Attachment := Obj.Get('attachment', Model.Attachment);
  Model.Temperature := Obj.Get('temperature', Model.Temperature);
  Model.ToolCall := Obj.Get('tool_call', Model.ToolCall);
  Node := Obj.Find('interleaved');
  if Assigned(Node) then
  begin
    if Node.JSONType = jtBoolean then
    begin
      if Node.AsBoolean then
        Model.Interleaved := 'true';
    end
    else if Node is TJSONObject then
    begin
      InterleavedObj := TJSONObject(Node);
      Model.Interleaved := InterleavedObj.Get('field', '');
    end;
  end;
  if Obj.Find('limit') is TJSONObject then
  begin
    Limit := TJSONObject(Obj.Find('limit'));
    Model.ContextLimit := Round(Limit.Get('context', Model.ContextLimit));
    Model.InputLimit := Round(Limit.Get('input', Model.InputLimit));
    Model.OutputLimit := Round(Limit.Get('output', Model.OutputLimit));
  end;
  if Obj.Find('modalities') is TJSONObject then
  begin
    Modalities := TJSONObject(Obj.Find('modalities'));
    if Assigned(Modalities.Find('input')) then
      Model.InputModalities := JsonArrayToCsv(Modalities.Find('input'));
    if Assigned(Modalities.Find('output')) then
      Model.OutputModalities := JsonArrayToCsv(Modalities.Find('output'));
  end;
  ApplyModelDefaults(Model);
end;

function ParseProviderModels(const ProviderId, ResponseText: string): TProviderModelInfoArray;
var
  Data, Node: TJSONData;
  Root, Item: TJSONObject;
  Arr: TJSONArray;
  I: Integer;
  Model: TProviderModelInfo;
begin
  Result := nil;
  SetLength(Result, 0);
  Data := GetJSON(ResponseText);
  try
    if not (Data is TJSONObject) then
      Exit;
    Root := TJSONObject(Data);
    if SameText(ProviderId, 'ollama') then
      Node := Root.Find('models')
    else
      Node := Root.Find('data');
    if (not Assigned(Node)) and Assigned(Root.Find('models')) then
      Node := Root.Find('models');
    if not (Node is TJSONArray) then
      Exit;
    Arr := TJSONArray(Node);
    for I := 0 to Arr.Count - 1 do
      if Arr.Items[I] is TJSONObject then
      begin
        Model := Default(TProviderModelInfo);
        Item := TJSONObject(Arr.Items[I]);
        if SameText(ProviderId, 'google') then
          Model.Id := ModelNameOnly(Item.Get('name', ''))
        else if SameText(ProviderId, 'ollama') then
          Model.Id := Item.Get('model', Item.Get('name', ''))
        else
          Model.Id := Item.Get('id', Item.Get('name', ''));
        Model.Name := Item.Get('displayName', Item.Get('name', Model.Id));
        ApplyModelObject(Model, Item);
        AddModel(Result, Model);
      end;
  finally
    Data.Free;
  end;
end;

procedure ApplyModelsDevCatalog(const ProviderId, ResponseText: string; var Models: TProviderModelInfoArray);
var
  Data, ProviderNode, ModelsNode, ModelNode: TJSONData;
  ProviderObj, CatalogModels, CatalogModel: TJSONObject;
  I, Index: Integer;
  ModelId, ShortId: string;
begin
  Data := GetJSON(ResponseText);
  try
    if not (Data is TJSONObject) then
      Exit;
    ProviderNode := TJSONObject(Data).Find(ProviderId);
    if not (ProviderNode is TJSONObject) then
      Exit;
    ProviderObj := TJSONObject(ProviderNode);
    ModelsNode := ProviderObj.Find('models');
    if not (ModelsNode is TJSONObject) then
      Exit;
    CatalogModels := TJSONObject(ModelsNode);
    for I := 0 to CatalogModels.Count - 1 do
    begin
      ModelId := CatalogModels.Names[I];
      ShortId := ModelNameOnly(ModelId);
      Index := FindModelIndex(Models, ModelId);
      if Index < 0 then
        Index := FindModelIndex(Models, ShortId);
      if Index < 0 then
        Continue;
      ModelNode := CatalogModels.Items[I];
      if ModelNode is TJSONObject then
      begin
        CatalogModel := TJSONObject(ModelNode);
        ApplyModelObject(Models[Index], CatalogModel);
      end;
    end;
  finally
    Data.Free;
  end;
end;

function FetchText(const URL, ApiKey: string; UseBearerAuth: Boolean = True): string;
var
  Client: TFPHTTPClient;
  Stream: TStringStream;
begin
  Client := TFPHTTPClient.Create(nil);
  try
    Client.ConnectTimeout := 10000;
    Client.IOTimeout := 20000;
    if UseBearerAuth and (ApiKey <> '') then
      Client.AddHeader('Authorization', 'Bearer ' + ApiKey);
    Stream := TStringStream.Create('', TEncoding.UTF8);
    try
      Client.Get(URL, Stream);
      Result := Stream.DataString;
    finally
      Stream.Free;
    end;
  finally
    Client.Free;
  end;
end;

function FetchProviderModels(const ProviderId, BaseURL, ApiKey: string): TProviderModelInfoArray;
var
  URL, Text, Catalog: string;
begin
  if BaseURL = '' then
    raise Exception.Create('Base URL 为空');
  URL := WithTrailingSlash(BaseURL);
  if SameText(ProviderId, 'ollama') then
    URL := URL + 'api/tags'
  else if SameText(ProviderId, 'google') then
    URL := URL + 'v1beta/models?key=' + ApiKey
  else
    URL := URL + 'models';
  Text := FetchText(URL, ApiKey, not SameText(ProviderId, 'google'));
  Result := ParseProviderModels(ProviderId, Text);
  try
    Catalog := FetchText('https://models.dev/api.json', '');
    ApplyModelsDevCatalog(ProviderId, Catalog, Result);
  except
    // Provider data is still useful; defaults cover missing capability fields.
  end;
end;

function TestModelConnectivity(const ProviderId, BaseURL, ApiKey, ModelId: string): TConnectivityResult;
var
  Client: TFPHTTPClient;
  RequestBody, URL: string;
  ResponseStream: TStringStream;
  Json: TJSONObject;
  StartTime: TDateTime;
begin
  Result.Success := False;
  Result.StatusCode := 0;
  Result.StatusText := '';
  Result.ResponseTimeMs := 0;
  Result.ErrorMessage := '';

  if BaseURL = '' then
  begin
    Result.ErrorMessage := 'Base URL 为空';
    Exit;
  end;

  if (ApiKey = '') and (CompareText(ProviderId, 'ollama') <> 0) then
  begin
    Result.ErrorMessage := 'API Key 为空';
    Exit;
  end;

  Client := TFPHTTPClient.Create(nil);
  try
    Client.AddHeader('Content-Type', 'application/json');
    Client.ConnectTimeout := 10000;
    Client.IOTimeout := 15000;

    URL := WithTrailingSlash(BaseURL);
    Json := TJSONObject.Create;
    try
      if CompareText(ProviderId, 'anthropic') = 0 then
      begin
        Client.AddHeader('x-api-key', ApiKey);
        Client.AddHeader('anthropic-version', '2023-06-01');
        if not EndsWithTextSimple(URL, 'v1/messages') then
          URL := URL + 'v1/messages';
        Json.Add('model', ModelNameOnly(ModelId));
        Json.Add('max_tokens', 1);
        Json.Add('messages', TJSONArray.Create([
          TJSONObject.Create(['role', 'user', 'content', 'ping'])
        ]));
      end
      else if CompareText(ProviderId, 'google') = 0 then
      begin
        URL := URL + 'v1beta/models/' + ModelNameOnly(ModelId) + ':generateContent?key=' + ApiKey;
        Json.Add('contents', TJSONArray.Create([
          TJSONObject.Create(['parts', TJSONArray.Create([TJSONObject.Create(['text', 'ping'])])])
        ]));
      end
      else if CompareText(ProviderId, 'ollama') = 0 then
      begin
        if not EndsWithTextSimple(URL, 'api/chat') then
          URL := URL + 'api/chat';
        Json.Add('model', ModelNameOnly(ModelId));
        Json.Add('stream', False);
        Json.Add('messages', TJSONArray.Create([
          TJSONObject.Create(['role', 'user', 'content', 'ping'])
        ]));
      end
      else
      begin
        Client.AddHeader('Authorization', 'Bearer ' + ApiKey);
        if not EndsWithTextSimple(URL, 'chat/completions') then
          URL := URL + 'chat/completions';
        Json.Add('model', ModelNameOnly(ModelId));
        Json.Add('max_tokens', 1);
        Json.Add('messages', TJSONArray.Create([
          TJSONObject.Create(['role', 'user', 'content', 'ping'])
        ]));
      end;
      RequestBody := Json.AsJSON;
    finally
      Json.Free;
    end;

    StartTime := Now;
    ResponseStream := TStringStream.Create('', TEncoding.UTF8);
    try
      try
        Client.RequestBody := TRawByteStringStream.Create(RequestBody);
        try
          Client.Post(URL, ResponseStream);
        finally
          Client.RequestBody.Free;
          Client.RequestBody := nil;
        end;
        Result.StatusCode := Client.ResponseStatusCode;
        Result.StatusText := Client.ResponseStatusText;
        Result.Success := (Result.StatusCode >= 200) and (Result.StatusCode < 300);
        if not Result.Success then
          Result.ErrorMessage := 'HTTP ' + IntToStr(Result.StatusCode) + ': ' + Result.StatusText;
      except
        on E: Exception do
        begin
          Result.ErrorMessage := E.Message;
          Result.StatusCode := Client.ResponseStatusCode;
        end;
      end;
    finally
      ResponseStream.Free;
    end;
    Result.ResponseTimeMs := Round((Now - StartTime) * 24 * 60 * 60 * 1000);
  finally
    Client.Free;
  end;
end;

end.
