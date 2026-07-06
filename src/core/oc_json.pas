unit oc_json;

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
    raise EJSONParser.Create('配置根节点必须是 JSON object');
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

end.
