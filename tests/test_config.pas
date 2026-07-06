unit test_config;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, fpjson, oc_config, oc_omo_config;

type
  TConfigTests = class(TTestCase)
  published
    procedure EmptyConfigListsAreSafe;
    procedure UpsertsProviderModelAgentMcpAndPlugin;
    procedure ValidatesInvalidAgentMode;
    procedure UpsertsOpenAgentAgentAndCategory;
  end;

implementation

procedure TConfigTests.EmptyConfigListsAreSafe;
var
  Cfg: TOpenCodeConfig;
  L: TStringList;
begin
  Cfg := TOpenCodeConfig.Create;
  try
    L := Cfg.ProviderIds;
    try
      AssertEquals(0, L.Count);
    finally
      L.Free;
    end;
    L := Cfg.AgentIds;
    try
      AssertEquals(0, L.Count);
    finally
      L.Free;
    end;
  finally
    Cfg.Free;
  end;
end;

procedure TConfigTests.UpsertsProviderModelAgentMcpAndPlugin;
var
  Cfg: TOpenCodeConfig;
  L: TStringList;
begin
  Cfg := TOpenCodeConfig.Create;
  try
    Cfg.UpsertProvider('openai-compatible', 'OpenAI Compatible', '@ai-sdk/openai-compatible', 'https://api.example.com/v1', '{env:API_KEY}');
    Cfg.UpsertModel('openai-compatible', 'coder-model', 'Coder Model');
    Cfg.UpsertAgent('review', 'Reviews code', 'subagent', 'openai-compatible/coder-model', 'Review only.', 0.1, False, '#336699', 12, True, 'read,grep');
    Cfg.UpsertMcpLocal('context7', 'npx -y @upstash/context7-mcp', True);
    Cfg.UpsertPlugin('oh-my-openagent@latest');

    L := Cfg.ProviderIds;
    try
      AssertEquals(1, L.IndexOf('openai-compatible') + 1);
    finally
      L.Free;
    end;
    AssertTrue(Pos('coder-model', Cfg.AsJson) > 0);
    AssertTrue(Pos('maxSteps', Cfg.AsJson) > 0);
    AssertTrue(Pos('read', Cfg.AsJson) > 0);
    AssertTrue(Pos('oh-my-openagent@latest', Cfg.AsJson) > 0);
  finally
    Cfg.Free;
  end;
end;

procedure TConfigTests.ValidatesInvalidAgentMode;
var
  Cfg: TOpenCodeConfig;
  Issues: TValidationIssueArray;
begin
  Cfg := TOpenCodeConfig.Create;
  try
    Cfg.UpsertAgent('bad', 'Bad agent', 'invalid', '', '', 0, False);
    Issues := Cfg.Validate;
    AssertTrue(Length(Issues) > 0);
    AssertEquals('error', Issues[0].Severity);
  finally
    Cfg.Free;
  end;
end;

procedure TConfigTests.UpsertsOpenAgentAgentAndCategory;
var
  Cfg: TOMOConfig;
  L: TStringList;
begin
  Cfg := TOMOConfig.Create;
  try
    Cfg.UpsertAgent('oracle', 'openai/gpt-5.5', 'ultrabrain', 'high', 'Think deeply.', 0.2, False, 'enabled', 'high');
    Cfg.UpsertCategory('quick', 'opencode/gpt-5-nano', 'Fast tasks', 'low', 'Be concise.', False, 'disabled', 'low');
    L := Cfg.AgentIds;
    try
      AssertTrue(L.IndexOf('oracle') >= 0);
    finally
      L.Free;
    end;
    AssertTrue(Pos('ultrabrain', Cfg.AsJson) > 0);
    AssertTrue(Pos('thinking', Cfg.AsJson) > 0);
    AssertTrue(Pos('reasoning', Cfg.AsJson) > 0);
    AssertTrue(Pos('opencode/gpt-5-nano', Cfg.AsJson) > 0);
  finally
    Cfg.Free;
  end;
end;

initialization
  RegisterTest(TConfigTests);
end.
