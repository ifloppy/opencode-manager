unit test_http;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, fpc_llm_api;

type
  THttpTests = class(TTestCase)
  published
    procedure ParsesOpenAICompatibleModels;
    procedure ParsesOllamaModels;
    procedure EnrichesFromModelsDevCatalog;
  end;

implementation

procedure THttpTests.ParsesOpenAICompatibleModels;
var
  Models: TProviderModelInfoArray;
begin
  Models := ParseProviderModels('openai', '{"data":[{"id":"gpt-test","name":"GPT Test"}]}');
  AssertEquals(1, Length(Models));
  AssertEquals('gpt-test', Models[0].Id);
  AssertEquals('GPT Test', Models[0].Name);
  AssertEquals(200000, Models[0].ContextLimit);
  AssertEquals(16000, Models[0].OutputLimit);
  AssertEquals('text', Models[0].InputModalities);
end;

procedure THttpTests.ParsesOllamaModels;
var
  Models: TProviderModelInfoArray;
begin
  Models := ParseProviderModels('ollama', '{"models":[{"model":"llama3.2:latest"}]}');
  AssertEquals(1, Length(Models));
  AssertEquals('llama3.2:latest', Models[0].Id);
end;

procedure THttpTests.EnrichesFromModelsDevCatalog;
var
  Models: TProviderModelInfoArray;
begin
  Models := ParseProviderModels('openai', '{"data":[{"id":"gpt-test"}]}');
  ApplyModelsDevCatalog('openai', '{"openai":{"models":{"openai/gpt-test":{"name":"GPT Test","family":"gpt","reasoning":true,"attachment":true,"tool_call":true,"temperature":true,"limit":{"context":128000,"output":32000},"modalities":{"input":["text","image"],"output":["text"]}}}}}', Models);
  AssertEquals(1, Length(Models));
  AssertEquals('GPT Test', Models[0].Name);
  AssertEquals('gpt', Models[0].Family);
  AssertTrue(Models[0].Reasoning);
  AssertTrue(Models[0].Attachment);
  AssertEquals(128000, Models[0].ContextLimit);
  AssertEquals(32000, Models[0].OutputLimit);
  AssertEquals('text,image', Models[0].InputModalities);
end;

initialization
  RegisterTest(THttpTests);
end.
