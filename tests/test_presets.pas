unit test_presets;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, oc_presets;

type
  TPresetTests = class(TTestCase)
  published
    procedure ProviderPresetsIncludeCommonSdks;
    procedure BuiltinAgentsAreKnown;
    procedure BuiltinOMOAgentsAreKnown;
  end;

implementation

procedure TPresetTests.ProviderPresetsIncludeCommonSdks;
begin
  AssertTrue(Length(PROVIDER_PRESETS) >= 16);
  AssertTrue(FindProviderPreset('anthropic') >= 0);
  AssertTrue(FindProviderPreset('openrouter') >= 0);
  AssertTrue(FindProviderPreset('ollama') >= 0);
  AssertTrue(Length(NPM_SDK_PRESETS) > 0);
end;

procedure TPresetTests.BuiltinAgentsAreKnown;
begin
  AssertTrue(IsBuiltinAgent('plan'));
  AssertTrue(IsBuiltinAgent('build'));
  AssertFalse(IsBuiltinAgent('custom-review'));
end;

procedure TPresetTests.BuiltinOMOAgentsAreKnown;
begin
  AssertTrue(IsBuiltinOMOAgent('Sisyphus'));
  AssertTrue(IsBuiltinOMOAgent('oracle'));
  AssertFalse(IsBuiltinOMOAgent('custom-omo'));
end;

initialization
  RegisterTest(TPresetTests);
end.
