unit test_sessions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, oc_sessions;

type
  TSessionTests = class(TTestCase)
  published
    procedure AggregatesJsonUsageByModel;
    procedure AggregatesJsonLines;
  end;

implementation

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

initialization
  RegisterTest(TSessionTests);
end.
