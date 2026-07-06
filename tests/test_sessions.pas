unit test_sessions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, sqlite3conn, sqldb, oc_paths, oc_sessions;

type
  TSessionTests = class(TTestCase)
  published
    procedure AggregatesJsonUsageByModel;
    procedure AggregatesJsonLines;
    procedure DiscoversHomeOpenCodeDatabase;
    procedure AggregatesSqliteSessions;
  end;

implementation

var
  TestHome: string = '';

function TestEnv(const Name: string): string;
begin
  if (Name = 'USERPROFILE') or (Name = 'HOME') then
    Result := TestHome
  else
    Result := '';
end;

procedure ExecSql(const DbPath, Sql: string);
var
  Conn: TSQLite3Connection;
  Tran: TSQLTransaction;
begin
  Conn := TSQLite3Connection.Create(nil);
  Tran := TSQLTransaction.Create(nil);
  try
    Conn.DatabaseName := DbPath;
    Conn.Transaction := Tran;
    Conn.Open;
    Tran.StartTransaction;
    Conn.ExecuteDirect(Sql);
    Tran.Commit;
  finally
    Tran.Free;
    Conn.Free;
  end;
end;

procedure CreateOpenCodeDb(const DbPath: string);
begin
  ForceDirectories(ExtractFileDir(DbPath));
  ExecSql(DbPath,
    'CREATE TABLE project (' +
    'id text PRIMARY KEY, worktree text NOT NULL, name text, time_created integer NOT NULL, time_updated integer NOT NULL, sandboxes text NOT NULL);');
  ExecSql(DbPath,
    'CREATE TABLE session (' +
    'id text PRIMARY KEY, project_id text NOT NULL, parent_id text, slug text NOT NULL, directory text NOT NULL, title text NOT NULL, version text NOT NULL, ' +
    'time_created integer NOT NULL, time_updated integer NOT NULL, workspace_id text, path text, agent text, model text, cost real DEFAULT 0 NOT NULL, ' +
    'tokens_input integer DEFAULT 0 NOT NULL, tokens_output integer DEFAULT 0 NOT NULL, tokens_reasoning integer DEFAULT 0 NOT NULL, ' +
    'tokens_cache_read integer DEFAULT 0 NOT NULL, tokens_cache_write integer DEFAULT 0 NOT NULL);');
end;

procedure TSessionTests.AggregatesJsonUsageByModel;
var
  Summary: TSessionUsageSummary;
begin
  FillChar(Summary, SizeOf(Summary), 0);
  ParseSessionText('proj', 'session-1', 'session-1.json', '{"messages":[{"model":"openai/gpt-5","usage":{"input_tokens":10,"output_tokens":5}},{"model":"openai/gpt-5","usage":{"prompt_tokens":7,"completion_tokens":3}},{"model":"anthropic/claude","usage":{"total_tokens":20}}]}', Summary);
  AssertEquals(Int64(45), Summary.Total.TotalTokens);
  AssertEquals(Int64(17), Summary.Total.InputTokens);
  AssertEquals(Int64(8), Summary.Total.OutputTokens);
  AssertEquals(2, Length(Summary.Models));
  AssertEquals(1, Length(Summary.Sessions));
  AssertEquals(Int64(45), Summary.Sessions[0].Usage.TotalTokens);
end;

procedure TSessionTests.AggregatesJsonLines;
var
  Summary: TSessionUsageSummary;
begin
  FillChar(Summary, SizeOf(Summary), 0);
  ParseSessionText('proj', 'session-2', 'session-2.jsonl', '{"model":"qwen/coder","usage":{"input":4,"output":6}}' + LineEnding + '{"model":"qwen/coder","tokens":{"input":2,"output":3}}', Summary);
  AssertEquals(Int64(15), Summary.Total.TotalTokens);
  AssertEquals(Int64(6), Summary.Total.InputTokens);
  AssertEquals(Int64(9), Summary.Total.OutputTokens);
  AssertEquals(1, Length(Summary.Models));
  AssertEquals('qwen/coder', Summary.Models[0].ModelName);
  AssertEquals(Int64(15), Summary.Models[0].Usage.TotalTokens);
end;

procedure TSessionTests.DiscoversHomeOpenCodeDatabase;
var
  Root, DbPath: string;
begin
  Root := IncludeTrailingPathDelimiter(GetTempDir) + 'oc-manager-db-discovery-' + IntToStr(GetTickCount64);
  DbPath := IncludeTrailingPathDelimiter(Root) + '.local' + DirectorySeparator + 'share' + DirectorySeparator + 'opencode' + DirectorySeparator + 'opencode.db';
  CreateOpenCodeDb(DbPath);
  TestHome := Root;
  SetEnvironmentReader(@TestEnv);
  try
    AssertEquals(ExpandFileName(DbPath), ExpandFileName(DiscoverOpenCodeDatabasePath));
  finally
    SetEnvironmentReader(nil);
  end;
end;

procedure TSessionTests.AggregatesSqliteSessions;
var
  Root, DbPath: string;
  Summary: TSessionUsageSummary;
begin
  Root := IncludeTrailingPathDelimiter(GetTempDir) + 'oc-manager-db-scan-' + IntToStr(GetTickCount64);
  DbPath := IncludeTrailingPathDelimiter(Root) + 'opencode.db';
  CreateOpenCodeDb(DbPath);
  ExecSql(DbPath,
    'INSERT INTO project (id, worktree, name, time_created, time_updated, sandboxes) VALUES (''p1'', ''D:\Project\one'', ''one'', 1, 1, ''[]'');');
  ExecSql(DbPath,
    'INSERT INTO session (id, project_id, slug, directory, title, version, time_created, time_updated, agent, model, cost, tokens_input, tokens_output, tokens_reasoning, tokens_cache_read, tokens_cache_write) ' +
    'VALUES (''s1'', ''p1'', ''slug-1'', ''D:\Project\one'', ''First'', ''1'', 1, 2, ''build'', ''{"id":"gpt-5","providerID":"openai"}'', 0.2, 10, 20, 3, 4, 5);');
  ExecSql(DbPath,
    'INSERT INTO session (id, project_id, slug, directory, title, version, time_created, time_updated, agent, model, cost, tokens_input, tokens_output, tokens_reasoning, tokens_cache_read, tokens_cache_write) ' +
    'VALUES (''s2'', ''p1'', ''slug-2'', ''D:\Project\one'', ''Second'', ''1'', 3, 4, ''plan'', ''{"id":"gpt-5","providerID":"openai"}'', 0.4, 7, 8, 0, 1, 2);');
  Summary := ScanOpenCodeDatabase(DbPath);
  AssertEquals(1, Summary.ProjectCount);
  AssertEquals(2, Summary.SessionCount);
  AssertEquals(1, Length(Summary.Models));
  AssertEquals(Int64(60), Summary.Total.TotalTokens);
  AssertEquals(Int64(17), Summary.Total.InputTokens);
  AssertEquals(Int64(28), Summary.Total.OutputTokens);
  AssertEquals(Int64(3), Summary.Total.ReasoningTokens);
  AssertEquals(Int64(5), Summary.Total.CacheReadTokens);
  AssertEquals(Int64(7), Summary.Total.CacheWriteTokens);
  AssertEquals('openai/gpt-5', Summary.Models[0].ModelName);
  AssertEquals('openai/gpt-5', Summary.Sessions[0].ModelName);
end;

initialization
  RegisterTest(TSessionTests);
end.
