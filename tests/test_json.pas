unit test_json;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, fpjson, fpc_jsonc;

type
  TJsonTests = class(TTestCase)
  published
    procedure ParsesJsoncCommentsAndTrailingCommas;
    procedure EnsuresObjectAndArray;
    procedure AtomicWriteCreatesFileAndBackup;
  end;

implementation

procedure TJsonTests.AtomicWriteCreatesFileAndBackup;
var
  Dir, Path, BackupDir: string;
  Backups: TStringList;
  SearchRec: TSearchRec;
begin
  Dir := IncludeTrailingPathDelimiter(GetTempDir) + 'ocm-jsonc-' + IntToStr(Random(MaxInt));
  ForceDirectories(Dir);
  Path := IncludeTrailingPathDelimiter(Dir) + 'demo.jsonc';
  AtomicWriteTextFile(Path, '{"a":1}', True);
  AssertTrue(FileExists(Path));
  AtomicWriteTextFile(Path, '{"a":2}', True);
  BackupDir := IncludeTrailingPathDelimiter(Dir) + 'backups';
  AssertTrue(DirectoryExists(BackupDir));
  Backups := TStringList.Create;
  try
    if FindFirst(IncludeTrailingPathDelimiter(BackupDir) + '*', faAnyFile, SearchRec) = 0 then
    try
      repeat
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') and ((SearchRec.Attr and faDirectory) = 0) then
          Backups.Add(SearchRec.Name);
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
    AssertTrue(Backups.Count >= 1);
  finally
    Backups.Free;
  end;
end;

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
