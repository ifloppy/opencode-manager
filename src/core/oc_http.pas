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

function TestModelConnectivity(const ProviderId, BaseURL, ApiKey, ModelId: string): TConnectivityResult;

implementation

uses
  fphttpclient, openssl, opensslsockets, fpjson, jsonparser;

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
