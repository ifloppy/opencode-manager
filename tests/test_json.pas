unit test_json;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, fpjson, oc_json;

type
  TJsonTests = class(TTestCase)
  published
    procedure ParsesJsoncCommentsAndTrailingCommas;
    procedure EnsuresObjectAndArray;
  end;

implementation

procedure TJsonTests.ParsesJsoncCommentsAndTrailingCommas;
var
  Obj: TJSONObject;
begin
  Obj := ParseJsonObject('{ // comment' + LineEnding + '"name": "demo", "items": [1,2,], }');
  try
    AssertEquals('demo', Obj.Get('name', ''));
    AssertTrue(Obj.Find('items') is TJSONArray);
    AssertEquals(2, TJSONArray(Obj.Find('items')).Count);
  finally
    Obj.Free;
  end;
end;

procedure TJsonTests.EnsuresObjectAndArray;
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.Create;
  try
    EnsureObject(Obj, 'provider');
    EnsureArray(Obj, 'plugin');
    AssertTrue(Obj.Find('provider') is TJSONObject);
    AssertTrue(Obj.Find('plugin') is TJSONArray);
  finally
    Obj.Free;
  end;
end;

initialization
  RegisterTest(TJsonTests);
end.
