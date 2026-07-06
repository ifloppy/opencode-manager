unit oc_presets;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TPresetProvider = record
    Id: string;
    Name: string;
    Npm: string;
    BaseURL: string;
  end;

const
  // Provider 预设
  PROVIDER_PRESETS: array[0..15] of TPresetProvider = (
    (Id: 'anthropic'; Name: 'Anthropic'; Npm: '@ai-sdk/anthropic'; BaseURL: 'https://api.anthropic.com'),
    (Id: 'openai'; Name: 'OpenAI'; Npm: '@ai-sdk/openai'; BaseURL: 'https://api.openai.com/v1'),
    (Id: 'google'; Name: 'Google'; Npm: '@ai-sdk/google'; BaseURL: 'https://generativelanguage.googleapis.com'),
    (Id: 'openrouter'; Name: 'OpenRouter'; Npm: '@ai-sdk/openai-compatible'; BaseURL: 'https://openrouter.ai/api/v1'),
    (Id: 'github-copilot'; Name: 'GitHub Copilot'; Npm: '@ai-sdk/openai'; BaseURL: ''),
    (Id: 'azure'; Name: 'Azure OpenAI'; Npm: '@ai-sdk/azure'; BaseURL: ''),
    (Id: 'bedrock'; Name: 'AWS Bedrock'; Npm: '@ai-sdk/amazon-bedrock'; BaseURL: ''),
    (Id: 'vertex'; Name: 'Google Vertex'; Npm: '@ai-sdk/google-vertex'; BaseURL: ''),
    (Id: 'mistral'; Name: 'Mistral'; Npm: '@ai-sdk/mistral'; BaseURL: 'https://api.mistral.ai/v1'),
    (Id: 'groq'; Name: 'Groq'; Npm: '@ai-sdk/groq'; BaseURL: 'https://api.groq.com/openai/v1'),
    (Id: 'deepseek'; Name: 'DeepSeek'; Npm: '@ai-sdk/deepseek'; BaseURL: 'https://api.deepseek.com/v1'),
    (Id: 'xai'; Name: 'xAI'; Npm: '@ai-sdk/xai'; BaseURL: 'https://api.x.ai/v1'),
    (Id: 'together'; Name: 'Together AI'; Npm: '@ai-sdk/openai-compatible'; BaseURL: 'https://api.together.xyz/v1'),
    (Id: 'fireworks'; Name: 'Fireworks AI'; Npm: '@ai-sdk/openai-compatible'; BaseURL: 'https://api.fireworks.ai/inference/v1'),
    (Id: 'perplexity'; Name: 'Perplexity'; Npm: '@ai-sdk/openai-compatible'; BaseURL: 'https://api.perplexity.ai'),
    (Id: 'ollama'; Name: 'Ollama'; Npm: '@ai-sdk/ollama'; BaseURL: 'http://localhost:11434')
  );

  // NPM SDK 预设
  NPM_SDK_PRESETS: array[0..10] of string = (
    '@ai-sdk/anthropic',
    '@ai-sdk/openai',
    '@ai-sdk/google',
    '@ai-sdk/openai-compatible',
    '@ai-sdk/amazon-bedrock',
    '@ai-sdk/azure',
    '@ai-sdk/mistral',
    '@ai-sdk/groq',
    '@ai-sdk/deepseek',
    '@ai-sdk/xai',
    '@ai-sdk/ollama'
  );

  // 内置 OpenCode Agent
  BUILTIN_AGENTS: array[0..1] of string = ('plan', 'build');

  // Agent 模式
  AGENT_MODES: array[0..2] of string = ('primary', 'subagent', 'all');

  // Agent 工具
  AGENT_TOOLS: array[0..11] of string = (
    'read', 'edit', 'bash', 'glob', 'grep', 'list',
    'task', 'skill', 'lsp', 'todoread', 'todowrite', 'webfetch'
  );

  // MCP 类型
  MCP_TYPES: array[0..2] of string = ('local', 'sse', 'remote');

  // OMO 内置 Agent
  OMO_BUILTIN_AGENTS: array[0..6] of string = (
    'Sisyphus', 'oracle', 'librarian',
    'frontend-ui-ux-engineer', 'document-writer',
    'multimodal-looker', 'explore'
  );

  // OMO Category 预设
  OMO_CATEGORY_PRESETS: array[0..4] of string = (
    'coding', 'review', 'docs', 'explore', 'multimodal'
  );

  // OMO Variant 预设
  OMO_VARIANT_PRESETS: array[0..3] of string = (
    'default', 'fast', 'thinking', 'reasoning'
  );

  // OMO Thinking 选项
  OMO_THINKING_OPTIONS: array[0..1] of string = ('enabled', 'disabled');

  // OMO Reasoning Effort 选项
  OMO_REASONING_EFFORTS: array[0..3] of string = ('low', 'medium', 'high', 'xhigh');

function FindProviderPreset(const Id: string): Integer;
function IsBuiltinAgent(const Id: string): Boolean;
function IsBuiltinOMOAgent(const Id: string): Boolean;

implementation

function FindProviderPreset(const Id: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := Low(PROVIDER_PRESETS) to High(PROVIDER_PRESETS) do
    if SameText(PROVIDER_PRESETS[I].Id, Id) then
      Exit(I);
end;

function IsBuiltinAgent(const Id: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(BUILTIN_AGENTS) to High(BUILTIN_AGENTS) do
    if SameText(BUILTIN_AGENTS[I], Id) then
      Exit(True);
end;

function IsBuiltinOMOAgent(const Id: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(OMO_BUILTIN_AGENTS) to High(OMO_BUILTIN_AGENTS) do
    if SameText(OMO_BUILTIN_AGENTS[I], Id) then
      Exit(True);
end;

end.
