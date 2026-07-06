unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, Spin, oc_config, oc_omo_config, oc_paths, oc_profiles,
  oc_presets, oc_http, oc_sessions;

type
  { TMainForm }

  TMainForm = class(TForm)
  private
    FConfig: TOpenCodeConfig;
    FOMO: TOMOConfig;
    FProfiles: TProfileManager;
    FModelListKeys: TStringList;
    FSessionSummary: TSessionUsageSummary;
    NavPanel: TPanel;
    PageControl: TPageControl;
    Status: TStatusBar;

    ConfigPathEdit: TEdit;
    OMOPathEdit: TEdit;
    ValidationMemo: TMemo;
    RawMemo: TMemo;
    OMORawMemo: TMemo;
    OverviewProviderLabel, OverviewModelLabel, OverviewAgentLabel, OverviewMcpLabel: TLabel;
    OverviewPluginLabel, OverviewOMOLabel, OverviewTokenLabel: TLabel;

    ProviderList, ModelList, AgentList, McpList, PluginList, ProfileList: TListBox;
    ProviderNameEdit, ProviderBaseUrlEdit, ProviderApiKeyEdit: TEdit;
    ProviderIdEdit, ProviderNpmEdit: TComboBox;
    ModelIdEdit, ModelNameEdit: TEdit;
    ProviderIdLabel, ProviderNameLabel, ProviderNpmLabel, ProviderBaseUrlLabel, ProviderApiKeyLabel: TLabel;
    ModelIdLabel, ModelNameLabel: TLabel;
    ProviderSaveButton, ProviderDeleteButton: TButton;
    ModelSaveButton, ModelDeleteButton, ModelTestButton: TButton;
    AgentIdEdit, AgentDescriptionEdit, AgentModelEdit, AgentColorEdit: TEdit;
    AgentModeEdit: TComboBox;
    AgentPromptMemo: TMemo;
    AgentIdLabel, AgentDescriptionLabel, AgentModeLabel, AgentModelLabel, AgentTempLabel: TLabel;
    AgentColorLabel, AgentMaxStepsLabel, AgentToolsLabel, AgentPromptLabel: TLabel;
    AgentTempEdit: TFloatSpinEdit;
    AgentMaxStepsEdit: TSpinEdit;
    AgentDisabledCheck, AgentHiddenCheck: TCheckBox;
    AgentToolChecks: array[0..11] of TCheckBox;
    AgentSaveButton, AgentDeleteButton: TButton;
    McpIdEdit, McpTargetEdit: TEdit;
    McpTypeEdit: TComboBox;
    McpEnabledCheck: TCheckBox;
    McpIdLabel, McpTypeLabel, McpTargetLabel, PluginNameLabel: TLabel;
    McpNewButton, McpSaveButton, McpDeleteButton: TButton;
    PluginNameEdit: TEdit;
    PluginNewButton, PluginSaveButton, PluginDeleteButton: TButton;
    ProfileNameEdit: TEdit;

    OMOAgentList, OMOCategoryList: TListBox;
    OMOAgentIdEdit, OMOAgentModelEdit: TEdit;
    OMOAgentCategoryEdit, OMOAgentVariantEdit, OMOAgentThinkingEdit, OMOAgentReasoningEdit: TComboBox;
    OMOAgentPromptMemo: TMemo;
    OMOAgentIdLabel, OMOAgentModelLabel, OMOAgentCategoryLabel, OMOAgentVariantLabel: TLabel;
    OMOAgentTempLabel, OMOAgentThinkingLabel, OMOAgentReasoningLabel: TLabel;
    OMOAgentTempEdit: TFloatSpinEdit;
    OMOAgentDisabledCheck: TCheckBox;
    OMOAgentSaveButton, OMOAgentDeleteButton: TButton;
    OMOCategoryIdEdit, OMOCategoryModelEdit, OMOCategoryDescEdit: TEdit;
    OMOCategoryVariantEdit, OMOCategoryThinkingEdit, OMOCategoryReasoningEdit: TComboBox;
    OMOCategoryPromptMemo: TMemo;
    OMOCategoryIdLabel, OMOCategoryModelLabel, OMOCategoryDescLabel, OMOCategoryVariantLabel: TLabel;
    OMOCategoryThinkingLabel, OMOCategoryReasoningLabel: TLabel;
    OMOCategoryDisabledCheck: TCheckBox;
    OMOCategorySaveButton, OMOCategoryDeleteButton: TButton;
    RawApplyButton: TButton;
    SessionPathEdit: TEdit;
    SessionProjectList, SessionList, SessionModelList: TListBox;
    SessionSummaryMemo: TMemo;
    SessionChart: TPaintBox;
    SessionRefreshButton: TButton;

    procedure BuildUi;
    procedure AdjustResponsiveLayout;
    function AddTab(const ACaption: string): TTabSheet;
    function AddNavButton(const ACaption: string; PageIndex: Integer): TButton;
    procedure UpdateNavigation;
    function AddButton(AParent: TWinControl; const ACaption: string; LeftPos, TopPos, WidthValue: Integer; Handler: TNotifyEvent): TButton;
    function AddLabel(AParent: TWinControl; const ACaption: string; LeftPos, TopPos: Integer): TLabel;
    function AddEdit(AParent: TWinControl; LeftPos, TopPos, WidthValue: Integer): TEdit;
    function AddCombo(AParent: TWinControl; LeftPos, TopPos, WidthValue: Integer; const Items: array of string): TComboBox;
    procedure FillCombo(ACombo: TComboBox; const Items: array of string);
    procedure LoadDefaultConfigs;
    procedure RefreshAll;
    procedure RefreshValidation;
    procedure RefreshRaw;
    procedure LoadRawIntoObjects;
    procedure RefreshProviderLists;
    procedure RefreshAgentList;
    procedure RefreshMcpList;
    procedure RefreshPluginList;
    procedure RefreshProfiles;
    procedure RefreshOMOLists;
    procedure RefreshOverviewStats;
    procedure RefreshSessionSummary;
    procedure PopulateSessionLists;
    function TotalModelCount: Integer;
    function SelectedText(List: TListBox): string;
    function SelectedModelId: string;
    function SelectedTools: string;
    procedure ApplyToolsToChecks(Agent: TJSONObject);
    function ObjectInSection(Root: TJSONObject; const Section, Id: string): TJSONObject;

    procedure OnOpenConfig(Sender: TObject);
    procedure OnFormResize(Sender: TObject);
    procedure OnNavButtonClick(Sender: TObject);
    procedure OnSaveConfig(Sender: TObject);
    procedure OnReload(Sender: TObject);
    procedure OnValidate(Sender: TObject);
    procedure OnApplyRaw(Sender: TObject);
    procedure OnProviderSelect(Sender: TObject);
    procedure OnProviderPresetChange(Sender: TObject);
    procedure OnModelSelect(Sender: TObject);
    procedure OnSaveProvider(Sender: TObject);
    procedure OnDeleteProvider(Sender: TObject);
    procedure OnSaveModel(Sender: TObject);
    procedure OnDeleteModel(Sender: TObject);
    procedure OnTestModelConnectivity(Sender: TObject);
    procedure OnAgentSelect(Sender: TObject);
    procedure OnSaveAgent(Sender: TObject);
    procedure OnDeleteAgent(Sender: TObject);
    procedure OnMcpSelect(Sender: TObject);
    procedure OnNewMcp(Sender: TObject);
    procedure OnSaveMcp(Sender: TObject);
    procedure OnDeleteMcp(Sender: TObject);
    procedure OnPluginSelect(Sender: TObject);
    procedure OnNewPlugin(Sender: TObject);
    procedure OnSavePlugin(Sender: TObject);
    procedure OnDeletePlugin(Sender: TObject);
    procedure OnCreateProfile(Sender: TObject);
    procedure OnDeleteProfile(Sender: TObject);
    procedure OnOMOAgentSelect(Sender: TObject);
    procedure OnSaveOMOAgent(Sender: TObject);
    procedure OnDeleteOMOAgent(Sender: TObject);
    procedure OnOMOCategorySelect(Sender: TObject);
    procedure OnSaveOMOCategory(Sender: TObject);
    procedure OnDeleteOMOCategory(Sender: TObject);
    procedure OnRefreshSessions(Sender: TObject);
    procedure OnSessionProjectSelect(Sender: TObject);
    procedure OnSessionSelect(Sender: TObject);
    procedure OnTokenChartPaint(Sender: TObject);
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainFormInstance: TMainForm;

implementation

constructor TMainForm.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  Caption := 'OpenCode 配置管理器';
  Width := 1180;
  Height := 780;
  Constraints.MinWidth := 1180;
  Constraints.MinHeight := 720;
  Position := poScreenCenter;
  FConfig := TOpenCodeConfig.Create;
  FOMO := TOMOConfig.Create;
  FProfiles := TProfileManager.Create;
  FModelListKeys := TStringList.Create;
  BuildUi;
  OnResize := @OnFormResize;
  LoadDefaultConfigs;
end;

destructor TMainForm.Destroy;
begin
  FProfiles.Free;
  FOMO.Free;
  FConfig.Free;
  FModelListKeys.Free;
  inherited Destroy;
end;

function TMainForm.AddTab(const ACaption: string): TTabSheet;
begin
  Result := TTabSheet.Create(PageControl);
  Result.PageControl := PageControl;
  Result.Caption := ACaption;
  Result.TabVisible := False;
  AddNavButton(ACaption, PageControl.PageCount - 1);
end;

function TMainForm.AddNavButton(const ACaption: string; PageIndex: Integer): TButton;
begin
  Result := TButton.Create(NavPanel);
  Result.Parent := NavPanel;
  Result.Caption := ACaption;
  Result.Tag := PageIndex;
  Result.SetBounds(12, 16 + PageIndex * 42, 176, 34);
  Result.Anchors := [akLeft, akTop, akRight];
  Result.OnClick := @OnNavButtonClick;
end;

procedure TMainForm.UpdateNavigation;
var
  I: Integer;
  Btn: TButton;
begin
  if not Assigned(NavPanel) then
    Exit;
  for I := 0 to NavPanel.ControlCount - 1 do
    if NavPanel.Controls[I] is TButton then
    begin
      Btn := TButton(NavPanel.Controls[I]);
      Btn.Enabled := Btn.Tag <> PageControl.ActivePageIndex;
    end;
end;

function TMainForm.AddButton(AParent: TWinControl; const ACaption: string; LeftPos, TopPos, WidthValue: Integer; Handler: TNotifyEvent): TButton;
begin
  Result := TButton.Create(AParent);
  Result.Parent := AParent;
  Result.Caption := ACaption;
  Result.Hint := ACaption;
  Result.ShowHint := True;
  Result.SetBounds(LeftPos, TopPos, WidthValue, 30);
  Result.OnClick := Handler;
end;

function TMainForm.AddLabel(AParent: TWinControl; const ACaption: string; LeftPos, TopPos: Integer): TLabel;
begin
  Result := TLabel.Create(AParent);
  Result.Parent := AParent;
  Result.Caption := ACaption;
  Result.Hint := ACaption;
  Result.SetBounds(LeftPos, TopPos, 120, 24);
end;

function TMainForm.AddEdit(AParent: TWinControl; LeftPos, TopPos, WidthValue: Integer): TEdit;
begin
  Result := TEdit.Create(AParent);
  Result.Parent := AParent;
  Result.ShowHint := True;
  Result.SetBounds(LeftPos, TopPos, WidthValue, 28);
end;

procedure TMainForm.FillCombo(ACombo: TComboBox; const Items: array of string);
var
  I: Integer;
begin
  ACombo.Items.Clear;
  for I := Low(Items) to High(Items) do
    ACombo.Items.Add(Items[I]);
end;

function TMainForm.AddCombo(AParent: TWinControl; LeftPos, TopPos, WidthValue: Integer; const Items: array of string): TComboBox;
begin
  Result := TComboBox.Create(AParent);
  Result.Parent := AParent;
  Result.Style := csDropDown;
  Result.ShowHint := True;
  Result.SetBounds(LeftPos, TopPos, WidthValue, 28);
  FillCombo(Result, Items);
end;

procedure TMainForm.BuildUi;
var
  Tab: TTabSheet;
  I: Integer;
begin
  NavPanel := TPanel.Create(Self);
  NavPanel.Parent := Self;
  NavPanel.Align := alLeft;
  NavPanel.Width := 200;
  NavPanel.BevelOuter := bvNone;
  NavPanel.Color := clBtnFace;

  PageControl := TPageControl.Create(Self);
  PageControl.Parent := Self;
  PageControl.Align := alClient;
  PageControl.TabPosition := tpTop;
  Status := TStatusBar.Create(Self);
  Status.Parent := Self;
  Status.Align := alBottom;

  Tab := AddTab('概览');
  OverviewProviderLabel := AddLabel(Tab, 'Provider: 0', 16, 18);
  OverviewModelLabel := AddLabel(Tab, 'Model: 0', 180, 18);
  OverviewAgentLabel := AddLabel(Tab, 'Agent: 0', 344, 18);
  OverviewMcpLabel := AddLabel(Tab, 'MCP: 0', 508, 18);
  OverviewPluginLabel := AddLabel(Tab, 'Plugin: 0', 672, 18);
  OverviewOMOLabel := AddLabel(Tab, 'OMO: 0 / 0', 836, 18);
  OverviewTokenLabel := AddLabel(Tab, '总 Token: 0', 16, 54);
  AddLabel(Tab, 'OpenCode 配置', 16, 94);
  ConfigPathEdit := AddEdit(Tab, 130, 90, 760);
  ConfigPathEdit.Anchors := [akLeft, akTop, akRight];
  AddButton(Tab, '打开', 900, 89, 80, @OnOpenConfig);
  AddButton(Tab, '保存全部', 990, 89, 100, @OnSaveConfig);
  AddLabel(Tab, 'OMO 配置', 16, 132);
  OMOPathEdit := AddEdit(Tab, 130, 128, 760);
  OMOPathEdit.Anchors := [akLeft, akTop, akRight];
  AddButton(Tab, '重新加载', 900, 127, 100, @OnReload);
  AddButton(Tab, '校验', 1010, 127, 80, @OnValidate);
  ValidationMemo := TMemo.Create(Tab);
  ValidationMemo.Parent := Tab;
  ValidationMemo.SetBounds(16, 174, 1070, 486);
  ValidationMemo.Anchors := [akLeft, akTop, akRight, akBottom];
  ValidationMemo.Hint := '配置路径、校验结果和结构问题';
  ValidationMemo.ShowHint := True;
  ValidationMemo.ScrollBars := ssAutoBoth;
  ValidationMemo.ReadOnly := True;

  Tab := AddTab('Provider / Model');
  ProviderList := TListBox.Create(Tab); ProviderList.Parent := Tab; ProviderList.SetBounds(16, 16, 210, 260); ProviderList.Hint := 'Provider 列表'; ProviderList.ShowHint := True; ProviderList.OnClick := @OnProviderSelect;
  ProviderIdLabel := AddLabel(Tab, 'Provider ID', 250, 20); ProviderIdEdit := AddCombo(Tab, 370, 16, 520, []); ProviderIdEdit.Anchors := [akLeft, akTop, akRight]; ProviderIdEdit.OnChange := @OnProviderPresetChange;
  for I := Low(PROVIDER_PRESETS) to High(PROVIDER_PRESETS) do
    ProviderIdEdit.Items.Add(PROVIDER_PRESETS[I].Id);
  ProviderNameLabel := AddLabel(Tab, '显示名', 250, 58); ProviderNameEdit := AddEdit(Tab, 370, 54, 520); ProviderNameEdit.Anchors := [akLeft, akTop, akRight];
  ProviderNpmLabel := AddLabel(Tab, 'NPM SDK', 250, 96); ProviderNpmEdit := AddCombo(Tab, 370, 92, 520, NPM_SDK_PRESETS); ProviderNpmEdit.Anchors := [akLeft, akTop, akRight];
  ProviderBaseUrlLabel := AddLabel(Tab, 'Base URL', 250, 134); ProviderBaseUrlEdit := AddEdit(Tab, 370, 130, 520); ProviderBaseUrlEdit.Anchors := [akLeft, akTop, akRight];
  ProviderApiKeyLabel := AddLabel(Tab, 'API Key', 250, 172); ProviderApiKeyEdit := AddEdit(Tab, 370, 168, 520); ProviderApiKeyEdit.Anchors := [akLeft, akTop, akRight];
  ProviderSaveButton := AddButton(Tab, '保存 Provider', 370, 210, 130, @OnSaveProvider);
  ProviderDeleteButton := AddButton(Tab, '删除 Provider', 510, 210, 130, @OnDeleteProvider);
  ModelList := TListBox.Create(Tab); ModelList.Parent := Tab; ModelList.SetBounds(16, 292, 210, 328); ModelList.Hint := '模型列表：选择后状态栏显示完整名称和 key'; ModelList.ShowHint := True; ModelList.OnClick := @OnModelSelect;
  ModelIdLabel := AddLabel(Tab, 'Model ID', 250, 292); ModelIdEdit := AddEdit(Tab, 370, 288, 520); ModelIdEdit.Anchors := [akLeft, akTop, akRight];
  ModelNameLabel := AddLabel(Tab, '模型显示名', 250, 330); ModelNameEdit := AddEdit(Tab, 370, 326, 520); ModelNameEdit.Anchors := [akLeft, akTop, akRight];
  ModelSaveButton := AddButton(Tab, '保存 Model', 370, 368, 130, @OnSaveModel);
  ModelDeleteButton := AddButton(Tab, '删除 Model', 510, 368, 130, @OnDeleteModel);
  ModelTestButton := AddButton(Tab, '测试连通性', 650, 368, 130, @OnTestModelConnectivity);

  Tab := AddTab('OpenCode Agent');
  AgentList := TListBox.Create(Tab); AgentList.Parent := Tab; AgentList.SetBounds(16, 16, 220, 610); AgentList.OnClick := @OnAgentSelect;
  AgentIdLabel := AddLabel(Tab, 'Agent ID', 260, 20); AgentIdEdit := AddEdit(Tab, 380, 16, 520);
  AgentDescriptionLabel := AddLabel(Tab, '描述', 260, 58); AgentDescriptionEdit := AddEdit(Tab, 380, 54, 520);
  AgentModeLabel := AddLabel(Tab, '模式', 260, 96); AgentModeEdit := AddCombo(Tab, 380, 92, 160, AGENT_MODES); AgentModeEdit.Text := 'subagent';
  AgentModelLabel := AddLabel(Tab, '模型', 260, 134); AgentModelEdit := AddEdit(Tab, 380, 130, 520);
  AgentTempLabel := AddLabel(Tab, '温度', 260, 172); AgentTempEdit := TFloatSpinEdit.Create(Tab); AgentTempEdit.Parent := Tab; AgentTempEdit.SetBounds(380, 168, 100, 28); AgentTempEdit.Increment := 0.1; AgentTempEdit.DecimalPlaces := 2; AgentTempEdit.MinValue := 0; AgentTempEdit.MaxValue := 2;
  AgentDisabledCheck := TCheckBox.Create(Tab); AgentDisabledCheck.Parent := Tab; AgentDisabledCheck.Caption := '禁用'; AgentDisabledCheck.SetBounds(500, 170, 80, 24);
  AgentHiddenCheck := TCheckBox.Create(Tab); AgentHiddenCheck.Parent := Tab; AgentHiddenCheck.Caption := '隐藏'; AgentHiddenCheck.SetBounds(580, 170, 80, 24);
  AgentColorLabel := AddLabel(Tab, '颜色', 610, 172); AgentColorEdit := AddEdit(Tab, 660, 168, 90);
  AgentMaxStepsLabel := AddLabel(Tab, 'MaxSteps', 760, 172); AgentMaxStepsEdit := TSpinEdit.Create(Tab); AgentMaxStepsEdit.Parent := Tab; AgentMaxStepsEdit.SetBounds(840, 168, 80, 28); AgentMaxStepsEdit.MinValue := 0; AgentMaxStepsEdit.MaxValue := 1000;
  AgentToolsLabel := AddLabel(Tab, '工具', 260, 210);
  for I := Low(AGENT_TOOLS) to High(AGENT_TOOLS) do
  begin
    AgentToolChecks[I] := TCheckBox.Create(Tab);
    AgentToolChecks[I].Parent := Tab;
    AgentToolChecks[I].Caption := AGENT_TOOLS[I];
    AgentToolChecks[I].SetBounds(380 + (I mod 4) * 120, 210 + (I div 4) * 26, 115, 24);
  end;
  AgentPromptLabel := AddLabel(Tab, 'Prompt', 260, 300); AgentPromptMemo := TMemo.Create(Tab); AgentPromptMemo.Parent := Tab; AgentPromptMemo.SetBounds(380, 300, 620, 210); AgentPromptMemo.ScrollBars := ssAutoBoth;
  AgentSaveButton := AddButton(Tab, '保存 Agent', 380, 530, 130, @OnSaveAgent);
  AgentDeleteButton := AddButton(Tab, '删除 Agent', 520, 530, 130, @OnDeleteAgent);

  Tab := AddTab('OMO Agents / Categories');
  OMOAgentList := TListBox.Create(Tab); OMOAgentList.Parent := Tab; OMOAgentList.SetBounds(16, 16, 210, 280); OMOAgentList.Hint := 'OMO Agent 列表，内置项可编辑或禁用但不能删除'; OMOAgentList.ShowHint := True; OMOAgentList.OnClick := @OnOMOAgentSelect;
  OMOAgentIdLabel := AddLabel(Tab, 'Agent ID', 245, 20); OMOAgentIdEdit := AddEdit(Tab, 365, 16, 300);
  OMOAgentModelLabel := AddLabel(Tab, '模型', 245, 58); OMOAgentModelEdit := AddEdit(Tab, 365, 54, 300);
  OMOAgentCategoryLabel := AddLabel(Tab, 'Category', 245, 96); OMOAgentCategoryEdit := AddCombo(Tab, 365, 92, 300, OMO_CATEGORY_PRESETS);
  OMOAgentVariantLabel := AddLabel(Tab, 'Variant', 245, 134); OMOAgentVariantEdit := AddCombo(Tab, 365, 130, 300, OMO_VARIANT_PRESETS);
  OMOAgentTempLabel := AddLabel(Tab, '温度', 245, 172); OMOAgentTempEdit := TFloatSpinEdit.Create(Tab); OMOAgentTempEdit.Parent := Tab; OMOAgentTempEdit.SetBounds(365, 168, 100, 28); OMOAgentTempEdit.Increment := 0.1; OMOAgentTempEdit.DecimalPlaces := 2; OMOAgentTempEdit.MaxValue := 2;
  OMOAgentDisabledCheck := TCheckBox.Create(Tab); OMOAgentDisabledCheck.Parent := Tab; OMOAgentDisabledCheck.Caption := '禁用'; OMOAgentDisabledCheck.SetBounds(490, 170, 80, 24);
  OMOAgentThinkingLabel := AddLabel(Tab, 'Thinking', 245, 210); OMOAgentThinkingEdit := AddCombo(Tab, 365, 206, 120, OMO_THINKING_OPTIONS);
  OMOAgentReasoningLabel := AddLabel(Tab, 'Reasoning', 500, 210); OMOAgentReasoningEdit := AddCombo(Tab, 590, 206, 120, OMO_REASONING_EFFORTS);
  OMOAgentPromptMemo := TMemo.Create(Tab); OMOAgentPromptMemo.Parent := Tab; OMOAgentPromptMemo.SetBounds(740, 16, 390, 250); OMOAgentPromptMemo.ScrollBars := ssAutoBoth; OMOAgentPromptMemo.Hint := 'OMO Agent prompt_append'; OMOAgentPromptMemo.ShowHint := True;
  OMOAgentSaveButton := AddButton(Tab, '保存 OMO Agent', 365, 245, 150, @OnSaveOMOAgent);
  OMOAgentDeleteButton := AddButton(Tab, '删除 OMO Agent', 525, 245, 150, @OnDeleteOMOAgent);
  OMOCategoryList := TListBox.Create(Tab); OMOCategoryList.Parent := Tab; OMOCategoryList.SetBounds(16, 330, 210, 280); OMOCategoryList.Hint := 'OMO Category 列表'; OMOCategoryList.ShowHint := True; OMOCategoryList.OnClick := @OnOMOCategorySelect;
  OMOCategoryIdLabel := AddLabel(Tab, 'Category ID', 245, 334); OMOCategoryIdEdit := AddEdit(Tab, 365, 330, 300);
  OMOCategoryModelLabel := AddLabel(Tab, '模型', 245, 372); OMOCategoryModelEdit := AddEdit(Tab, 365, 368, 300);
  OMOCategoryDescLabel := AddLabel(Tab, '描述', 245, 410); OMOCategoryDescEdit := AddEdit(Tab, 365, 406, 300);
  OMOCategoryVariantLabel := AddLabel(Tab, 'Variant', 245, 448); OMOCategoryVariantEdit := AddCombo(Tab, 365, 444, 300, OMO_VARIANT_PRESETS);
  OMOCategoryDisabledCheck := TCheckBox.Create(Tab); OMOCategoryDisabledCheck.Parent := Tab; OMOCategoryDisabledCheck.Caption := '禁用'; OMOCategoryDisabledCheck.SetBounds(365, 482, 80, 24);
  OMOCategoryThinkingLabel := AddLabel(Tab, 'Thinking', 245, 524); OMOCategoryThinkingEdit := AddCombo(Tab, 365, 520, 120, OMO_THINKING_OPTIONS);
  OMOCategoryReasoningLabel := AddLabel(Tab, 'Reasoning', 500, 524); OMOCategoryReasoningEdit := AddCombo(Tab, 590, 520, 120, OMO_REASONING_EFFORTS);
  OMOCategoryPromptMemo := TMemo.Create(Tab); OMOCategoryPromptMemo.Parent := Tab; OMOCategoryPromptMemo.SetBounds(740, 330, 390, 250); OMOCategoryPromptMemo.ScrollBars := ssAutoBoth; OMOCategoryPromptMemo.Hint := 'OMO Category prompt_append'; OMOCategoryPromptMemo.ShowHint := True;
  OMOCategorySaveButton := AddButton(Tab, '保存 Category', 365, 560, 150, @OnSaveOMOCategory);
  OMOCategoryDeleteButton := AddButton(Tab, '删除 Category', 525, 560, 150, @OnDeleteOMOCategory);

  Tab := AddTab('MCP / Plugin');
  McpList := TListBox.Create(Tab); McpList.Parent := Tab; McpList.SetBounds(16, 16, 220, 300); McpList.Hint := 'MCP 列表'; McpList.ShowHint := True; McpList.OnClick := @OnMcpSelect;
  McpIdLabel := AddLabel(Tab, 'MCP ID', 260, 20); McpIdEdit := AddEdit(Tab, 380, 16, 260);
  McpTypeLabel := AddLabel(Tab, '类型', 260, 58); McpTypeEdit := AddCombo(Tab, 380, 54, 160, MCP_TYPES); McpTypeEdit.Text := 'local';
  McpTargetLabel := AddLabel(Tab, '命令或 URL', 260, 96); McpTargetEdit := AddEdit(Tab, 380, 92, 520);
  McpEnabledCheck := TCheckBox.Create(Tab); McpEnabledCheck.Parent := Tab; McpEnabledCheck.Caption := '启用'; McpEnabledCheck.Checked := True; McpEnabledCheck.SetBounds(380, 130, 80, 24);
  McpNewButton := AddButton(Tab, '新增 MCP', 380, 170, 130, @OnNewMcp);
  McpSaveButton := AddButton(Tab, '保存 MCP', 520, 170, 130, @OnSaveMcp);
  McpDeleteButton := AddButton(Tab, '删除 MCP', 660, 170, 130, @OnDeleteMcp);
  PluginList := TListBox.Create(Tab); PluginList.Parent := Tab; PluginList.SetBounds(16, 350, 220, 260); PluginList.Hint := 'Plugin 包列表'; PluginList.ShowHint := True; PluginList.OnClick := @OnPluginSelect;
  PluginNameLabel := AddLabel(Tab, 'Plugin 包名', 260, 354); PluginNameEdit := AddEdit(Tab, 380, 350, 360);
  PluginNewButton := AddButton(Tab, '新增 Plugin', 380, 390, 130, @OnNewPlugin);
  PluginSaveButton := AddButton(Tab, '保存 Plugin', 520, 390, 130, @OnSavePlugin);
  PluginDeleteButton := AddButton(Tab, '删除 Plugin', 660, 390, 130, @OnDeletePlugin);

  Tab := AddTab('Profile');
  ProfileList := TListBox.Create(Tab); ProfileList.Parent := Tab; ProfileList.SetBounds(16, 16, 260, 590); ProfileList.Anchors := [akLeft, akTop, akBottom];
  AddLabel(Tab, 'Profile 名称', 310, 20); ProfileNameEdit := AddEdit(Tab, 430, 16, 260);
  AddButton(Tab, '从当前配置创建', 430, 58, 160, @OnCreateProfile);
  AddButton(Tab, '删除 Profile', 600, 58, 130, @OnDeleteProfile);
  AddLabel(Tab, 'Profile 根目录: ' + FProfiles.RootDir, 310, 110);

  Tab := AddTab('聊天记录');
  AddLabel(Tab, '会话目录', 16, 20); SessionPathEdit := AddEdit(Tab, 130, 16, 700); SessionPathEdit.Anchors := [akLeft, akTop, akRight];
  SessionRefreshButton := AddButton(Tab, '刷新统计', 850, 15, 120, @OnRefreshSessions);
  SessionProjectList := TListBox.Create(Tab); SessionProjectList.Parent := Tab; SessionProjectList.SetBounds(16, 64, 220, 260); SessionProjectList.OnClick := @OnSessionProjectSelect;
  SessionList := TListBox.Create(Tab); SessionList.Parent := Tab; SessionList.SetBounds(252, 64, 260, 260); SessionList.OnClick := @OnSessionSelect;
  SessionModelList := TListBox.Create(Tab); SessionModelList.Parent := Tab; SessionModelList.SetBounds(16, 342, 496, 260);
  SessionSummaryMemo := TMemo.Create(Tab); SessionSummaryMemo.Parent := Tab; SessionSummaryMemo.SetBounds(528, 64, 540, 180); SessionSummaryMemo.ReadOnly := True; SessionSummaryMemo.ScrollBars := ssAutoVertical;
  SessionChart := TPaintBox.Create(Tab); SessionChart.Parent := Tab; SessionChart.SetBounds(528, 260, 540, 342); SessionChart.OnPaint := @OnTokenChartPaint;

  Tab := AddTab('原始 JSON');
  RawMemo := TMemo.Create(Tab); RawMemo.Parent := Tab; RawMemo.SetBounds(16, 16, 520, 590); RawMemo.ScrollBars := ssAutoBoth;
  OMORawMemo := TMemo.Create(Tab); OMORawMemo.Parent := Tab; OMORawMemo.SetBounds(552, 16, 520, 590); OMORawMemo.ScrollBars := ssAutoBoth;
  RawApplyButton := AddButton(Tab, '从原始 JSON 应用', 16, 620, 160, @OnApplyRaw);
  PageControl.ActivePageIndex := 0;
  UpdateNavigation;
  AdjustResponsiveLayout;
end;

procedure TMainForm.AdjustResponsiveLayout;
var
  W, H, ListGap, ListHeight, FieldX, FieldW, RightEdge, RawWidth: Integer;
  ButtonTop, PromptTop, PromptH, RightX, RightW, SectionH, FormW, ModelTop, PluginTop: Integer;
  ToolCols, ToolW, ToolX, ToolY, I: Integer;
begin
  if Assigned(ValidationMemo) then
  begin
    W := ValidationMemo.Parent.ClientWidth;
    ValidationMemo.SetBounds(16, 174, W - 32, ValidationMemo.Parent.ClientHeight - 190);
  end;

  if Assigned(ProviderList) then
  begin
    W := ProviderList.Parent.ClientWidth;
    H := ProviderList.Parent.ClientHeight;
    ListGap := 16;
    ListHeight := (H - 48) div 2;
    if ListHeight < 190 then
      ListHeight := 190;
    FieldX := 370;
    RightEdge := W - 16;
    FieldW := RightEdge - FieldX;
    if FieldW < 360 then
      FieldW := 360;
    ProviderList.SetBounds(16, 16, 210, ListHeight);
    ModelTop := 16 + ListHeight + ListGap;
    ModelList.SetBounds(16, ModelTop, 210, H - (16 + ModelTop));
    ProviderIdLabel.SetBounds(250, 20, 120, 24);
    ProviderIdEdit.SetBounds(FieldX, 16, FieldW, 28);
    ProviderNameLabel.SetBounds(250, 58, 120, 24);
    ProviderNameEdit.SetBounds(FieldX, 54, FieldW, 28);
    ProviderNpmLabel.SetBounds(250, 96, 120, 24);
    ProviderNpmEdit.SetBounds(FieldX, 92, FieldW, 28);
    ProviderBaseUrlLabel.SetBounds(250, 134, 120, 24);
    ProviderBaseUrlEdit.SetBounds(FieldX, 130, FieldW, 28);
    ProviderApiKeyLabel.SetBounds(250, 172, 120, 24);
    ProviderApiKeyEdit.SetBounds(FieldX, 168, FieldW, 28);
    ProviderSaveButton.SetBounds(FieldX, 210, 130, 30);
    ProviderDeleteButton.SetBounds(FieldX + 150, 210, 130, 30);
    ModelIdLabel.SetBounds(250, ModelTop + 4, 120, 24);
    ModelIdEdit.SetBounds(FieldX, ModelTop, FieldW, 28);
    ModelNameLabel.SetBounds(250, ModelTop + 42, 120, 24);
    ModelNameEdit.SetBounds(FieldX, ModelTop + 38, FieldW, 28);
    ModelSaveButton.SetBounds(FieldX, ModelTop + 80, 130, 30);
    ModelDeleteButton.SetBounds(FieldX + 150, ModelTop + 80, 130, 30);
    ModelTestButton.SetBounds(FieldX + 300, ModelTop + 80, 130, 30);
  end;

  if Assigned(AgentList) then
  begin
    W := AgentList.Parent.ClientWidth;
    H := AgentList.Parent.ClientHeight;
    FieldX := 380;
    RightEdge := W - 16;
    FieldW := RightEdge - FieldX;
    if FieldW < 420 then
      FieldW := 420;
    AgentList.SetBounds(16, 16, 220, H - 32);
    AgentIdLabel.SetBounds(260, 20, 120, 24);
    AgentIdEdit.SetBounds(FieldX, 16, FieldW, 28);
    AgentDescriptionLabel.SetBounds(260, 58, 120, 24);
    AgentDescriptionEdit.SetBounds(FieldX, 54, FieldW, 28);
    AgentModeLabel.SetBounds(260, 96, 120, 24);
    AgentModeEdit.SetBounds(FieldX, 92, 160, 28);
    AgentModelLabel.SetBounds(260, 134, 120, 24);
    AgentModelEdit.SetBounds(FieldX, 130, FieldW, 28);
    AgentTempLabel.SetBounds(260, 172, 120, 24);
    AgentTempEdit.SetBounds(FieldX, 168, 100, 28);
    AgentDisabledCheck.SetBounds(FieldX + 120, 170, 80, 24);
    AgentHiddenCheck.SetBounds(FieldX + 210, 170, 80, 24);
    AgentColorLabel.SetBounds(260, 210, 120, 24);
    AgentColorEdit.SetBounds(FieldX, 206, 120, 28);
    AgentMaxStepsLabel.SetBounds(FieldX + 150, 210, 90, 24);
    AgentMaxStepsEdit.SetBounds(FieldX + 240, 206, 90, 28);
    AgentToolsLabel.SetBounds(260, 250, 120, 24);
    ToolCols := 4;
    if FieldW < 560 then
      ToolCols := 3;
    if FieldW < 430 then
      ToolCols := 2;
    ToolW := FieldW div ToolCols;
    for I := Low(AgentToolChecks) to High(AgentToolChecks) do
    begin
      ToolX := FieldX + (I mod ToolCols) * ToolW;
      ToolY := 250 + (I div ToolCols) * 26;
      AgentToolChecks[I].SetBounds(ToolX, ToolY, ToolW - 8, 24);
    end;
    PromptTop := 250 + ((High(AgentToolChecks) + ToolCols) div ToolCols) * 26 + 18;
    AgentPromptLabel.SetBounds(260, PromptTop, 120, 24);
    PromptH := H - PromptTop - 76;
    if PromptH < 120 then
      PromptH := 120;
    AgentPromptMemo.SetBounds(FieldX, PromptTop, FieldW, PromptH);
    ButtonTop := PromptTop + PromptH + 16;
    AgentSaveButton.SetBounds(FieldX, ButtonTop, 130, 30);
    AgentDeleteButton.SetBounds(FieldX + 150, ButtonTop, 130, 30);
  end;

  if Assigned(RawMemo) then
  begin
    W := RawMemo.Parent.ClientWidth;
    H := RawMemo.Parent.ClientHeight;
    RawWidth := (W - 64) div 2;
    if RawWidth < 240 then
      RawWidth := 240;
    RawMemo.SetBounds(16, 16, RawWidth, H - 72);
    OMORawMemo.SetBounds(32 + RawWidth, 16, W - RawWidth - 48, H - 72);
    RawApplyButton.SetBounds(16, H - 44, 180, 30);
  end;

  if Assigned(OMOAgentPromptMemo) then
  begin
    W := OMOAgentPromptMemo.Parent.ClientWidth;
    H := OMOAgentPromptMemo.Parent.ClientHeight;
    OMOAgentList.SetBounds(16, 16, 210, 280);
    OMOCategoryList.SetBounds(16, 330, 210, H - 346);
    FormW := 300;
    RightX := W - 360;
    if RightX < 720 then
      RightX := 720;
    if W - RightX < 240 then
      RightX := W - 256;
    if RightX < 700 then
      RightX := 700;
    RightW := W - RightX - 16;
    if RightW < 220 then
      RightW := 220;
    if RightX - 365 - 20 < FormW then
      FormW := RightX - 385;
    if FormW < 240 then
      FormW := 240;
    OMOAgentIdLabel.SetBounds(245, 20, 120, 24);
    OMOAgentIdEdit.SetBounds(365, 16, FormW, 28);
    OMOAgentModelLabel.SetBounds(245, 58, 120, 24);
    OMOAgentModelEdit.SetBounds(365, 54, FormW, 28);
    OMOAgentCategoryLabel.SetBounds(245, 96, 120, 24);
    OMOAgentCategoryEdit.SetBounds(365, 92, FormW, 28);
    OMOAgentVariantLabel.SetBounds(245, 134, 120, 24);
    OMOAgentVariantEdit.SetBounds(365, 130, FormW, 28);
    OMOAgentTempLabel.SetBounds(245, 172, 120, 24);
    OMOAgentTempEdit.SetBounds(365, 168, 100, 28);
    OMOAgentDisabledCheck.SetBounds(490, 170, 80, 24);
    OMOAgentThinkingLabel.SetBounds(245, 210, 120, 24);
    OMOAgentThinkingEdit.SetBounds(365, 206, 120, 28);
    OMOAgentReasoningLabel.SetBounds(500, 210, 80, 24);
    OMOAgentReasoningEdit.SetBounds(580, 206, 110, 28);
    OMOAgentSaveButton.SetBounds(365, 245, 150, 30);
    OMOAgentDeleteButton.SetBounds(525, 245, 150, 30);
    OMOCategoryIdLabel.SetBounds(245, 334, 120, 24);
    OMOCategoryIdEdit.SetBounds(365, 330, FormW, 28);
    OMOCategoryModelLabel.SetBounds(245, 372, 120, 24);
    OMOCategoryModelEdit.SetBounds(365, 368, FormW, 28);
    OMOCategoryDescLabel.SetBounds(245, 410, 120, 24);
    OMOCategoryDescEdit.SetBounds(365, 406, FormW, 28);
    OMOCategoryVariantLabel.SetBounds(245, 448, 120, 24);
    OMOCategoryVariantEdit.SetBounds(365, 444, FormW, 28);
    OMOCategoryDisabledCheck.SetBounds(365, 482, 80, 24);
    OMOCategoryThinkingLabel.SetBounds(245, 524, 120, 24);
    OMOCategoryThinkingEdit.SetBounds(365, 520, 120, 28);
    OMOCategoryReasoningLabel.SetBounds(500, 524, 80, 24);
    OMOCategoryReasoningEdit.SetBounds(580, 520, 110, 28);
    OMOCategorySaveButton.SetBounds(365, 560, 150, 30);
    OMOCategoryDeleteButton.SetBounds(525, 560, 150, 30);
    OMOAgentPromptMemo.SetBounds(RightX, 16, RightW, 280);
    OMOCategoryPromptMemo.SetBounds(RightX, 330, RightW, H - 346);
  end;

  if Assigned(McpList) then
  begin
    W := McpList.Parent.ClientWidth;
    H := McpList.Parent.ClientHeight;
    FieldX := 380;
    FieldW := W - FieldX - 16;
    if FieldW < 360 then
      FieldW := 360;
    SectionH := (H - 64) div 2;
    if SectionH < 210 then
      SectionH := 210;
    McpList.SetBounds(16, 16, 220, SectionH);
    PluginTop := 48 + SectionH;
    PluginList.SetBounds(16, PluginTop, 220, H - SectionH - 64);
    McpIdLabel.SetBounds(260, 20, 120, 24);
    McpIdEdit.SetBounds(FieldX, 16, FieldW, 28);
    McpTypeLabel.SetBounds(260, 58, 120, 24);
    McpTypeEdit.SetBounds(FieldX, 54, 160, 28);
    McpTargetLabel.SetBounds(260, 96, 120, 24);
    McpTargetEdit.SetBounds(FieldX, 92, FieldW, 28);
    McpEnabledCheck.SetBounds(FieldX, 130, 80, 24);
    McpNewButton.SetBounds(FieldX, 170, 130, 30);
    McpSaveButton.SetBounds(FieldX + 150, 170, 130, 30);
    McpDeleteButton.SetBounds(FieldX + 300, 170, 130, 30);
    PluginNameLabel.SetBounds(260, PluginTop + 4, 120, 24);
    PluginNameEdit.SetBounds(FieldX, PluginTop, FieldW, 28);
    PluginNewButton.SetBounds(FieldX, PluginTop + 40, 130, 30);
    PluginSaveButton.SetBounds(FieldX + 150, PluginTop + 40, 130, 30);
    PluginDeleteButton.SetBounds(FieldX + 300, PluginTop + 40, 130, 30);
  end;

  if Assigned(SessionProjectList) then
  begin
    W := SessionProjectList.Parent.ClientWidth;
    H := SessionProjectList.Parent.ClientHeight;
    SessionPathEdit.SetBounds(130, 16, W - 280, 28);
    SessionRefreshButton.SetBounds(W - 136, 15, 120, 30);
    SectionH := (H - 110) div 2;
    if SectionH < 180 then
      SectionH := 180;
    SessionProjectList.SetBounds(16, 64, 220, SectionH);
    SessionList.SetBounds(252, 64, 260, SectionH);
    SessionModelList.SetBounds(16, 84 + SectionH, 496, H - SectionH - 100);
    SessionSummaryMemo.SetBounds(528, 64, W - 544, 180);
    SessionChart.SetBounds(528, 260, W - 544, H - 276);
  end;
end;

procedure TMainForm.LoadDefaultConfigs;
begin
  ConfigPathEdit.Text := GetOpenCodeConfigFile;
  OMOPathEdit.Text := GetOpenAgentConfigFile(ExtractFileDir(ConfigPathEdit.Text));
  FConfig.LoadFromFile(ConfigPathEdit.Text);
  FOMO.LoadFromFile(OMOPathEdit.Text);
  RefreshAll;
end;

procedure TMainForm.RefreshAll;
begin
  RefreshProviderLists;
  RefreshAgentList;
  RefreshMcpList;
  RefreshPluginList;
  RefreshProfiles;
  RefreshOMOLists;
  RefreshValidation;
  RefreshRaw;
  RefreshSessionSummary;
  RefreshOverviewStats;
  Status.SimpleText := '已加载: ' + ConfigPathEdit.Text;
end;

function TMainForm.TotalModelCount: Integer;
var
  Providers, Models: TStringList;
  I: Integer;
begin
  Result := 0;
  Providers := FConfig.ProviderIds;
  try
    for I := 0 to Providers.Count - 1 do
    begin
      Models := FConfig.ModelIds(Providers[I]);
      try
        Inc(Result, Models.Count);
      finally
        Models.Free;
      end;
    end;
  finally
    Providers.Free;
  end;
end;

procedure TMainForm.RefreshOverviewStats;
var
  L: TStringList;
  ProviderCount, AgentCount, McpCount, PluginCount, OMOAgentCount, OMOCategoryCount: Integer;
begin
  L := FConfig.ProviderIds;
  try
    ProviderCount := L.Count;
  finally
    L.Free;
  end;
  L := FConfig.AgentIds;
  try
    AgentCount := L.Count;
  finally
    L.Free;
  end;
  L := FConfig.McpIds;
  try
    McpCount := L.Count;
  finally
    L.Free;
  end;
  L := FConfig.Plugins;
  try
    PluginCount := L.Count;
  finally
    L.Free;
  end;
  L := FOMO.AgentIds;
  try
    OMOAgentCount := L.Count;
  finally
    L.Free;
  end;
  L := FOMO.CategoryIds;
  try
    OMOCategoryCount := L.Count;
  finally
    L.Free;
  end;
  OverviewProviderLabel.Caption := 'Provider: ' + IntToStr(ProviderCount);
  OverviewModelLabel.Caption := 'Model: ' + IntToStr(TotalModelCount);
  OverviewAgentLabel.Caption := 'Agent: ' + IntToStr(AgentCount);
  OverviewMcpLabel.Caption := 'MCP: ' + IntToStr(McpCount);
  OverviewPluginLabel.Caption := 'Plugin: ' + IntToStr(PluginCount);
  OverviewOMOLabel.Caption := 'OMO: ' + IntToStr(OMOAgentCount) + ' / ' + IntToStr(OMOCategoryCount);
  OverviewTokenLabel.Caption := '总 Token: ' + IntToStr(FSessionSummary.Total.TotalTokens) +
    '  输入: ' + IntToStr(FSessionSummary.Total.InputTokens) +
    '  输出: ' + IntToStr(FSessionSummary.Total.OutputTokens);
end;

procedure TMainForm.RefreshSessionSummary;
begin
  if not Assigned(SessionPathEdit) then
    Exit;
  if SessionPathEdit.Text = '' then
    SessionPathEdit.Text := DiscoverOpenCodeSessionsDir(ExtractFileDir(ConfigPathEdit.Text));
  FSessionSummary := ScanOpenCodeSessions(SessionPathEdit.Text);
  PopulateSessionLists;
  if Assigned(SessionChart) then
    SessionChart.Invalidate;
end;

procedure TMainForm.PopulateSessionLists;
var
  I: Integer;
  ProjectName: string;
begin
  if not Assigned(SessionProjectList) then
    Exit;
  SessionProjectList.Clear;
  SessionList.Clear;
  SessionModelList.Clear;
  for I := 0 to High(FSessionSummary.Sessions) do
  begin
    ProjectName := FSessionSummary.Sessions[I].ProjectName;
    if SessionProjectList.Items.IndexOf(ProjectName) < 0 then
      SessionProjectList.Items.Add(ProjectName);
    SessionList.Items.Add(ProjectName + ' | ' + FSessionSummary.Sessions[I].SessionName + ' | ' + IntToStr(FSessionSummary.Sessions[I].Usage.TotalTokens));
  end;
  for I := 0 to High(FSessionSummary.Models) do
    SessionModelList.Items.Add(FSessionSummary.Models[I].ModelName + '  总:' + IntToStr(FSessionSummary.Models[I].Usage.TotalTokens) +
      ' 输入:' + IntToStr(FSessionSummary.Models[I].Usage.InputTokens) +
      ' 输出:' + IntToStr(FSessionSummary.Models[I].Usage.OutputTokens));
  SessionSummaryMemo.Clear;
  SessionSummaryMemo.Lines.Add('项目数: ' + IntToStr(FSessionSummary.ProjectCount));
  SessionSummaryMemo.Lines.Add('会话数: ' + IntToStr(FSessionSummary.SessionCount));
  SessionSummaryMemo.Lines.Add('总 Token: ' + IntToStr(FSessionSummary.Total.TotalTokens));
  SessionSummaryMemo.Lines.Add('输入 Token: ' + IntToStr(FSessionSummary.Total.InputTokens));
  SessionSummaryMemo.Lines.Add('输出 Token: ' + IntToStr(FSessionSummary.Total.OutputTokens));
  SessionSummaryMemo.Lines.Add('目录: ' + FSessionSummary.RootDir);
end;

procedure TMainForm.RefreshValidation;
var
  Issues: TValidationIssueArray;
  Issue: TValidationIssue;
begin
  ValidationMemo.Clear;
  ValidationMemo.Lines.Add('OpenCode 配置: ' + ConfigPathEdit.Text);
  Issues := FConfig.Validate;
  for Issue in Issues do
    ValidationMemo.Lines.Add('[' + Issue.Severity + '] ' + Issue.Message);
  ValidationMemo.Lines.Add('');
  ValidationMemo.Lines.Add('Oh My OpenAgent 配置: ' + OMOPathEdit.Text);
  Issues := FOMO.Validate;
  for Issue in Issues do
    ValidationMemo.Lines.Add('[' + Issue.Severity + '] ' + Issue.Message);
end;

procedure TMainForm.RefreshRaw;
begin
  RawMemo.Text := FConfig.AsJson;
  OMORawMemo.Text := FOMO.AsJson;
end;

procedure TMainForm.LoadRawIntoObjects;
begin
  FConfig.LoadFromString(RawMemo.Text);
  FOMO.LoadFromString(OMORawMemo.Text);
end;

function TMainForm.SelectedText(List: TListBox): string;
begin
  if Assigned(List) and (List.ItemIndex >= 0) then
    Result := List.Items[List.ItemIndex]
  else
    Result := '';
end;

function TMainForm.SelectedModelId: string;
begin
  if (ModelList.ItemIndex >= 0) and (ModelList.ItemIndex < FModelListKeys.Count) then
    Result := FModelListKeys[ModelList.ItemIndex]
  else
    Result := ModelIdEdit.Text;
end;

function TMainForm.SelectedTools: string;
var
  I: Integer;
begin
  Result := '';
  for I := Low(AgentToolChecks) to High(AgentToolChecks) do
    if AgentToolChecks[I].Checked then
    begin
      if Result <> '' then
        Result := Result + ',';
      Result := Result + AGENT_TOOLS[I];
    end;
end;

procedure TMainForm.ApplyToolsToChecks(Agent: TJSONObject);
var
  I: Integer;
  Tools: TJSONData;
begin
  for I := Low(AgentToolChecks) to High(AgentToolChecks) do
    AgentToolChecks[I].Checked := False;
  if not Assigned(Agent) then
    Exit;
  Tools := Agent.Find('tools');
  if Tools is TJSONObject then
    for I := Low(AgentToolChecks) to High(AgentToolChecks) do
      AgentToolChecks[I].Checked := TJSONObject(Tools).Get(AGENT_TOOLS[I], False);
end;

function TMainForm.ObjectInSection(Root: TJSONObject; const Section, Id: string): TJSONObject;
var
  Sec, Item: TJSONData;
begin
  Result := nil;
  Sec := Root.Find(Section);
  if Sec is TJSONObject then
  begin
    Item := TJSONObject(Sec).Find(Id);
    if Item is TJSONObject then
      Result := TJSONObject(Item);
  end;
end;

procedure TMainForm.RefreshProviderLists;
var
  L: TStringList;
begin
  L := FConfig.ProviderIds;
  try
    ProviderList.Items.Assign(L);
  finally
    L.Free;
  end;
  ModelList.Clear;
  FModelListKeys.Clear;
end;

procedure TMainForm.RefreshAgentList;
var
  L: TStringList;
  I: Integer;
begin
  L := FConfig.AgentIds;
  try
    for I := Low(BUILTIN_AGENTS) to High(BUILTIN_AGENTS) do
      if L.IndexOf(BUILTIN_AGENTS[I]) < 0 then
        L.Add(BUILTIN_AGENTS[I]);
    AgentList.Items.Assign(L);
  finally
    L.Free;
  end;
end;

procedure TMainForm.RefreshMcpList;
var
  L: TStringList;
begin
  L := FConfig.McpIds;
  try
    McpList.Items.Assign(L);
  finally
    L.Free;
  end;
end;

procedure TMainForm.RefreshPluginList;
var
  L: TStringList;
begin
  L := FConfig.Plugins;
  try
    PluginList.Items.Assign(L);
  finally
    L.Free;
  end;
end;

procedure TMainForm.RefreshProfiles;
var
  L: TStringList;
begin
  L := FProfiles.Profiles;
  try
    ProfileList.Items.Assign(L);
  finally
    L.Free;
  end;
end;

procedure TMainForm.RefreshOMOLists;
var
  L: TStringList;
  I: Integer;
begin
  L := FOMO.AgentIds;
  try
    for I := Low(OMO_BUILTIN_AGENTS) to High(OMO_BUILTIN_AGENTS) do
      if L.IndexOf(OMO_BUILTIN_AGENTS[I]) < 0 then
        L.Add(OMO_BUILTIN_AGENTS[I]);
    OMOAgentList.Items.Assign(L);
  finally
    L.Free;
  end;
  L := FOMO.CategoryIds;
  try
    OMOCategoryList.Items.Assign(L);
  finally
    L.Free;
  end;
end;

procedure TMainForm.OnOpenConfig(Sender: TObject);
var
  D: TOpenDialog;
begin
  D := TOpenDialog.Create(Self);
  try
    D.Filter := 'OpenCode JSON|*.json;*.jsonc|所有文件|*.*';
    if D.Execute then
    begin
      ConfigPathEdit.Text := D.FileName;
      OMOPathEdit.Text := GetOpenAgentConfigFile(ExtractFileDir(D.FileName));
      FConfig.LoadFromFile(ConfigPathEdit.Text);
      FOMO.LoadFromFile(OMOPathEdit.Text);
      RefreshAll;
    end;
  finally
    D.Free;
  end;
end;

procedure TMainForm.OnNavButtonClick(Sender: TObject);
begin
  if Sender is TButton then
  begin
    PageControl.ActivePageIndex := TButton(Sender).Tag;
    UpdateNavigation;
    AdjustResponsiveLayout;
  end;
end;

procedure TMainForm.OnFormResize(Sender: TObject);
begin
  AdjustResponsiveLayout;
end;

procedure TMainForm.OnSaveConfig(Sender: TObject);
begin
  FConfig.SaveToFile(ConfigPathEdit.Text);
  FOMO.SaveToFile(OMOPathEdit.Text);
  RefreshAll;
  ShowMessage('已保存配置，并在 backups 目录创建备份。');
end;

procedure TMainForm.OnReload(Sender: TObject);
begin
  FConfig.LoadFromFile(ConfigPathEdit.Text);
  FOMO.LoadFromFile(OMOPathEdit.Text);
  RefreshAll;
end;

procedure TMainForm.OnValidate(Sender: TObject);
begin
  RefreshValidation;
end;

procedure TMainForm.OnApplyRaw(Sender: TObject);
begin
  LoadRawIntoObjects;
  RefreshAll;
end;

procedure TMainForm.OnProviderSelect(Sender: TObject);
var
  Provider, Options, Models, ModelObj: TJSONObject;
  L: TStringList;
  I: Integer;
  ModelId, DisplayName: string;
begin
  ProviderIdEdit.Text := SelectedText(ProviderList);
  Provider := ObjectInSection(FConfig.Data, 'provider', ProviderIdEdit.Text);
  if Assigned(Provider) then
  begin
    ProviderNameEdit.Text := Provider.Get('name', '');
    ProviderNpmEdit.Text := Provider.Get('npm', '');
    if Provider.Find('options') is TJSONObject then
    begin
      Options := TJSONObject(Provider.Find('options'));
      ProviderBaseUrlEdit.Text := Options.Get('baseURL', '');
      ProviderApiKeyEdit.Text := Options.Get('apiKey', '');
    end;
  end;
  L := FConfig.ModelIds(ProviderIdEdit.Text);
  try
    ModelList.Clear;
    FModelListKeys.Clear;
    Models := nil;
    if Assigned(Provider) and (Provider.Find('models') is TJSONObject) then
      Models := TJSONObject(Provider.Find('models'));
    for I := 0 to L.Count - 1 do
    begin
      ModelId := L[I];
      DisplayName := '';
      if Assigned(Models) and (Models.Find(ModelId) is TJSONObject) then
      begin
        ModelObj := TJSONObject(Models.Find(ModelId));
        DisplayName := ModelObj.Get('name', '');
      end;
      if DisplayName <> '' then
        ModelList.Items.Add(DisplayName + ' (' + ModelId + ')')
      else
        ModelList.Items.Add(ModelId);
      FModelListKeys.Add(ModelId);
    end;
    ModelList.Hint := '模型列表：选择后状态栏显示完整名称和 key。当前 ' + IntToStr(ModelList.Items.Count) + ' 项。';
  finally
    L.Free;
  end;
end;

procedure TMainForm.OnProviderPresetChange(Sender: TObject);
var
  Index: Integer;
begin
  Index := FindProviderPreset(ProviderIdEdit.Text);
  if Index < 0 then
    Exit;
  ProviderNameEdit.Text := PROVIDER_PRESETS[Index].Name;
  ProviderNpmEdit.Text := PROVIDER_PRESETS[Index].Npm;
  ProviderBaseUrlEdit.Text := PROVIDER_PRESETS[Index].BaseURL;
end;

procedure TMainForm.OnModelSelect(Sender: TObject);
var
  Provider, Models, ModelObj: TJSONObject;
begin
  ModelIdEdit.Text := SelectedModelId;
  ModelNameEdit.Text := '';
  ModelIdEdit.Hint := ModelIdEdit.Text;
  Provider := ObjectInSection(FConfig.Data, 'provider', ProviderIdEdit.Text);
  if Assigned(Provider) and (Provider.Find('models') is TJSONObject) then
  begin
    Models := TJSONObject(Provider.Find('models'));
    if Models.Find(ModelIdEdit.Text) is TJSONObject then
    begin
      ModelObj := TJSONObject(Models.Find(ModelIdEdit.Text));
      ModelNameEdit.Text := ModelObj.Get('name', '');
      ModelNameEdit.Hint := ModelNameEdit.Text;
    end;
  end;
  if ModelNameEdit.Text <> '' then
    Status.SimpleText := '模型: ' + ModelNameEdit.Text + ' / ' + ModelIdEdit.Text
  else
    Status.SimpleText := '模型: ' + ModelIdEdit.Text;
end;

procedure TMainForm.OnSaveProvider(Sender: TObject);
begin
  FConfig.UpsertProvider(ProviderIdEdit.Text, ProviderNameEdit.Text, ProviderNpmEdit.Text, ProviderBaseUrlEdit.Text, ProviderApiKeyEdit.Text);
  RefreshAll;
end;

procedure TMainForm.OnDeleteProvider(Sender: TObject);
begin
  FConfig.DeleteProvider(ProviderIdEdit.Text);
  RefreshAll;
end;

procedure TMainForm.OnSaveModel(Sender: TObject);
begin
  FConfig.UpsertModel(ProviderIdEdit.Text, ModelIdEdit.Text, ModelNameEdit.Text);
  RefreshAll;
end;

procedure TMainForm.OnDeleteModel(Sender: TObject);
begin
  FConfig.DeleteModel(ProviderIdEdit.Text, SelectedModelId);
  RefreshAll;
end;

procedure TMainForm.OnTestModelConnectivity(Sender: TObject);
var
  R: TConnectivityResult;
begin
  R := TestModelConnectivity(ProviderIdEdit.Text, ProviderBaseUrlEdit.Text, ProviderApiKeyEdit.Text, ModelIdEdit.Text);
  if R.Success then
  begin
    Status.SimpleText := '模型连通性测试成功: HTTP ' + IntToStr(R.StatusCode) + ', ' + IntToStr(R.ResponseTimeMs) + 'ms';
    ShowMessage(Status.SimpleText);
  end
  else
  begin
    Status.SimpleText := '模型连通性测试失败: ' + R.ErrorMessage;
    ShowMessage(Status.SimpleText);
  end;
end;

procedure TMainForm.OnAgentSelect(Sender: TObject);
var
  Agent: TJSONObject;
begin
  AgentIdEdit.Text := SelectedText(AgentList);
  AgentDescriptionEdit.Text := '';
  AgentModeEdit.Text := 'primary';
  AgentModelEdit.Text := '';
  AgentPromptMemo.Text := '';
  AgentTempEdit.Value := 0.0;
  AgentDisabledCheck.Checked := False;
  AgentHiddenCheck.Checked := False;
  AgentColorEdit.Text := '';
  AgentMaxStepsEdit.Value := 0;
  ApplyToolsToChecks(nil);
  AgentDeleteButton.Enabled := not IsBuiltinAgent(AgentIdEdit.Text);
  Agent := ObjectInSection(FConfig.Data, 'agent', AgentIdEdit.Text);
  if Assigned(Agent) then
  begin
    AgentDescriptionEdit.Text := Agent.Get('description', '');
    AgentModeEdit.Text := Agent.Get('mode', 'all');
    AgentModelEdit.Text := Agent.Get('model', '');
    AgentPromptMemo.Text := Agent.Get('prompt', '');
    AgentTempEdit.Value := Agent.Get('temperature', 0.0);
    AgentDisabledCheck.Checked := Agent.Get('disable', False);
    AgentHiddenCheck.Checked := Agent.Get('hidden', False);
    AgentColorEdit.Text := Agent.Get('color', '');
    AgentMaxStepsEdit.Value := Agent.Get('maxSteps', 0);
    ApplyToolsToChecks(Agent);
  end;
end;

procedure TMainForm.OnSaveAgent(Sender: TObject);
begin
  FConfig.UpsertAgent(AgentIdEdit.Text, AgentDescriptionEdit.Text, AgentModeEdit.Text, AgentModelEdit.Text, AgentPromptMemo.Text,
    AgentTempEdit.Value, AgentDisabledCheck.Checked, AgentColorEdit.Text, AgentMaxStepsEdit.Value, AgentHiddenCheck.Checked, SelectedTools);
  RefreshAll;
end;

procedure TMainForm.OnDeleteAgent(Sender: TObject);
begin
  if IsBuiltinAgent(AgentIdEdit.Text) then
  begin
    ShowMessage('内置 Agent 不能删除，只能编辑或禁用。');
    Exit;
  end;
  FConfig.DeleteAgent(AgentIdEdit.Text);
  RefreshAll;
end;

procedure TMainForm.OnMcpSelect(Sender: TObject);
var
  Mcp: TJSONObject;
  Cmd: TJSONArray;
  I: Integer;
begin
  McpIdEdit.Text := SelectedText(McpList);
  Mcp := ObjectInSection(FConfig.Data, 'mcp', McpIdEdit.Text);
  if Assigned(Mcp) then
  begin
    McpTypeEdit.Text := Mcp.Get('type', 'local');
    McpEnabledCheck.Checked := Mcp.Get('enabled', True);
    if (LowerCase(McpTypeEdit.Text) = 'remote') or (LowerCase(McpTypeEdit.Text) = 'sse') then
      McpTargetEdit.Text := Mcp.Get('url', '')
    else if Mcp.Find('command') is TJSONArray then
    begin
      Cmd := TJSONArray(Mcp.Find('command'));
      McpTargetEdit.Text := '';
      for I := 0 to Cmd.Count - 1 do
      begin
        if I > 0 then McpTargetEdit.Text := McpTargetEdit.Text + ' ';
        McpTargetEdit.Text := McpTargetEdit.Text + Cmd.Strings[I];
      end;
    end;
  end;
end;

procedure TMainForm.OnNewMcp(Sender: TObject);
begin
  McpList.ItemIndex := -1;
  McpIdEdit.Text := '';
  McpTypeEdit.Text := 'local';
  McpTargetEdit.Text := '';
  McpEnabledCheck.Checked := True;
  Status.SimpleText := '请输入新的 MCP ID、类型和命令或 URL，然后点击保存 MCP。';
end;

procedure TMainForm.OnSaveMcp(Sender: TObject);
begin
  if (LowerCase(McpTypeEdit.Text) = 'remote') or (LowerCase(McpTypeEdit.Text) = 'sse') then
    FConfig.UpsertMcpRemote(McpIdEdit.Text, McpTargetEdit.Text, McpEnabledCheck.Checked, LowerCase(McpTypeEdit.Text))
  else
    FConfig.UpsertMcpLocal(McpIdEdit.Text, McpTargetEdit.Text, McpEnabledCheck.Checked);
  RefreshAll;
end;

procedure TMainForm.OnDeleteMcp(Sender: TObject);
begin
  FConfig.DeleteMcp(McpIdEdit.Text);
  RefreshAll;
end;

procedure TMainForm.OnPluginSelect(Sender: TObject);
begin
  PluginNameEdit.Text := SelectedText(PluginList);
  PluginNameEdit.Hint := PluginNameEdit.Text;
end;

procedure TMainForm.OnNewPlugin(Sender: TObject);
begin
  PluginList.ItemIndex := -1;
  PluginNameEdit.Text := '';
  PluginNameEdit.Hint := '输入新的 Plugin 包名，例如 npm 包名或本地插件路径';
  Status.SimpleText := '请输入新的 Plugin 包名，然后点击保存 Plugin。';
end;

procedure TMainForm.OnSavePlugin(Sender: TObject);
begin
  FConfig.UpsertPlugin(PluginNameEdit.Text);
  RefreshAll;
end;

procedure TMainForm.OnDeletePlugin(Sender: TObject);
begin
  FConfig.DeletePlugin(PluginNameEdit.Text);
  RefreshAll;
end;

procedure TMainForm.OnCreateProfile(Sender: TObject);
begin
  FProfiles.CreateProfile(ProfileNameEdit.Text, ExtractFileDir(ConfigPathEdit.Text));
  RefreshProfiles;
end;

procedure TMainForm.OnDeleteProfile(Sender: TObject);
begin
  FProfiles.DeleteProfile(SelectedText(ProfileList));
  RefreshProfiles;
end;

procedure TMainForm.OnOMOAgentSelect(Sender: TObject);
var
  Agent: TJSONObject;
  Node: TJSONData;
begin
  OMOAgentIdEdit.Text := SelectedText(OMOAgentList);
  OMOAgentModelEdit.Text := '';
  OMOAgentCategoryEdit.Text := '';
  OMOAgentVariantEdit.Text := '';
  OMOAgentPromptMemo.Text := '';
  OMOAgentTempEdit.Value := 0.0;
  OMOAgentDisabledCheck.Checked := False;
  OMOAgentThinkingEdit.Text := '';
  OMOAgentReasoningEdit.Text := '';
  OMOAgentDeleteButton.Enabled := not IsBuiltinOMOAgent(OMOAgentIdEdit.Text);
  Agent := ObjectInSection(FOMO.Data, 'agents', OMOAgentIdEdit.Text);
  if Assigned(Agent) then
  begin
    OMOAgentModelEdit.Text := Agent.Get('model', '');
    OMOAgentCategoryEdit.Text := Agent.Get('category', '');
    OMOAgentVariantEdit.Text := Agent.Get('variant', '');
    OMOAgentPromptMemo.Text := Agent.Get('prompt_append', '');
    OMOAgentTempEdit.Value := Agent.Get('temperature', 0.0);
    OMOAgentDisabledCheck.Checked := Agent.Get('disable', False);
    Node := Agent.Find('thinking');
    if Node is TJSONObject then
      OMOAgentThinkingEdit.Text := TJSONObject(Node).Get('type', '');
    Node := Agent.Find('reasoning');
    if Node is TJSONObject then
      OMOAgentReasoningEdit.Text := TJSONObject(Node).Get('effort', '');
  end;
end;

procedure TMainForm.OnSaveOMOAgent(Sender: TObject);
begin
  FOMO.UpsertAgent(OMOAgentIdEdit.Text, OMOAgentModelEdit.Text, OMOAgentCategoryEdit.Text, OMOAgentVariantEdit.Text,
    OMOAgentPromptMemo.Text, OMOAgentTempEdit.Value, OMOAgentDisabledCheck.Checked, OMOAgentThinkingEdit.Text, OMOAgentReasoningEdit.Text);
  RefreshAll;
end;

procedure TMainForm.OnDeleteOMOAgent(Sender: TObject);
begin
  if IsBuiltinOMOAgent(OMOAgentIdEdit.Text) then
  begin
    ShowMessage('内置 OMO Agent 不能删除，只能编辑或禁用。');
    Exit;
  end;
  FOMO.DeleteAgent(OMOAgentIdEdit.Text);
  RefreshAll;
end;

procedure TMainForm.OnOMOCategorySelect(Sender: TObject);
var
  Category: TJSONObject;
  Node: TJSONData;
begin
  OMOCategoryIdEdit.Text := SelectedText(OMOCategoryList);
  OMOCategoryModelEdit.Text := '';
  OMOCategoryDescEdit.Text := '';
  OMOCategoryVariantEdit.Text := '';
  OMOCategoryPromptMemo.Text := '';
  OMOCategoryDisabledCheck.Checked := False;
  OMOCategoryThinkingEdit.Text := '';
  OMOCategoryReasoningEdit.Text := '';
  Category := ObjectInSection(FOMO.Data, 'categories', OMOCategoryIdEdit.Text);
  if Assigned(Category) then
  begin
    OMOCategoryModelEdit.Text := Category.Get('model', '');
    OMOCategoryDescEdit.Text := Category.Get('description', '');
    OMOCategoryVariantEdit.Text := Category.Get('variant', '');
    OMOCategoryPromptMemo.Text := Category.Get('prompt_append', '');
    OMOCategoryDisabledCheck.Checked := Category.Get('disable', False);
    Node := Category.Find('thinking');
    if Node is TJSONObject then
      OMOCategoryThinkingEdit.Text := TJSONObject(Node).Get('type', '');
    Node := Category.Find('reasoning');
    if Node is TJSONObject then
      OMOCategoryReasoningEdit.Text := TJSONObject(Node).Get('effort', '');
  end;
end;

procedure TMainForm.OnSaveOMOCategory(Sender: TObject);
begin
  FOMO.UpsertCategory(OMOCategoryIdEdit.Text, OMOCategoryModelEdit.Text, OMOCategoryDescEdit.Text, OMOCategoryVariantEdit.Text,
    OMOCategoryPromptMemo.Text, OMOCategoryDisabledCheck.Checked, OMOCategoryThinkingEdit.Text, OMOCategoryReasoningEdit.Text);
  RefreshAll;
end;

procedure TMainForm.OnDeleteOMOCategory(Sender: TObject);
begin
  FOMO.DeleteCategory(OMOCategoryIdEdit.Text);
  RefreshAll;
end;

procedure TMainForm.OnRefreshSessions(Sender: TObject);
begin
  FSessionSummary := ScanOpenCodeSessions(SessionPathEdit.Text);
  PopulateSessionLists;
  RefreshOverviewStats;
  SessionChart.Invalidate;
end;

procedure TMainForm.OnSessionProjectSelect(Sender: TObject);
var
  I: Integer;
  ProjectName: string;
begin
  ProjectName := SelectedText(SessionProjectList);
  SessionList.Clear;
  for I := 0 to High(FSessionSummary.Sessions) do
    if (ProjectName = '') or (FSessionSummary.Sessions[I].ProjectName = ProjectName) then
      SessionList.Items.Add(FSessionSummary.Sessions[I].ProjectName + ' | ' + FSessionSummary.Sessions[I].SessionName + ' | ' + IntToStr(FSessionSummary.Sessions[I].Usage.TotalTokens));
end;

procedure TMainForm.OnSessionSelect(Sender: TObject);
var
  I: Integer;
  DisplayText: string;
begin
  DisplayText := SelectedText(SessionList);
  for I := 0 to High(FSessionSummary.Sessions) do
    if DisplayText = FSessionSummary.Sessions[I].ProjectName + ' | ' + FSessionSummary.Sessions[I].SessionName + ' | ' + IntToStr(FSessionSummary.Sessions[I].Usage.TotalTokens) then
    begin
      SessionSummaryMemo.Clear;
      SessionSummaryMemo.Lines.Add('项目: ' + FSessionSummary.Sessions[I].ProjectName);
      SessionSummaryMemo.Lines.Add('会话: ' + FSessionSummary.Sessions[I].SessionName);
      SessionSummaryMemo.Lines.Add('总 Token: ' + IntToStr(FSessionSummary.Sessions[I].Usage.TotalTokens));
      SessionSummaryMemo.Lines.Add('输入 Token: ' + IntToStr(FSessionSummary.Sessions[I].Usage.InputTokens));
      SessionSummaryMemo.Lines.Add('输出 Token: ' + IntToStr(FSessionSummary.Sessions[I].Usage.OutputTokens));
      SessionSummaryMemo.Lines.Add('文件: ' + FSessionSummary.Sessions[I].FileName);
      Exit;
    end;
end;

procedure TMainForm.OnTokenChartPaint(Sender: TObject);
var
  C: TCanvas;
  I, LeftPos, TopPos, BarWidth, BarHeight, MaxHeight, LabelY: Integer;
  MaxTokens: Int64;
  Scale: Double;
  ChartW, ChartH: Integer;
begin
  C := SessionChart.Canvas;
  ChartW := SessionChart.Width;
  ChartH := SessionChart.Height;
  C.Brush.Color := clWhite;
  C.FillRect(0, 0, ChartW, ChartH);
  C.Pen.Color := clGray;
  C.Rectangle(0, 0, ChartW, ChartH);
  C.Font.Color := clBlack;
  C.TextOut(12, 10, '按模型 Token 用量');
  if Length(FSessionSummary.Models) = 0 then
  begin
    C.TextOut(12, 36, '未找到可统计的会话 usage 数据');
    Exit;
  end;
  MaxTokens := 1;
  for I := 0 to High(FSessionSummary.Models) do
    if FSessionSummary.Models[I].Usage.TotalTokens > MaxTokens then
      MaxTokens := FSessionSummary.Models[I].Usage.TotalTokens;
  MaxHeight := ChartH - 86;
  if MaxHeight < 40 then
    MaxHeight := 40;
  BarWidth := (ChartW - 40) div Length(FSessionSummary.Models);
  if BarWidth > 90 then
    BarWidth := 90;
  if BarWidth < 24 then
    BarWidth := 24;
  Scale := MaxHeight / MaxTokens;
  LabelY := ChartH - 44;
  for I := 0 to High(FSessionSummary.Models) do
  begin
    LeftPos := 20 + I * BarWidth;
    BarHeight := Round(FSessionSummary.Models[I].Usage.TotalTokens * Scale);
    TopPos := LabelY - BarHeight;
    C.Brush.Color := RGBToColor(54, 117, 202);
    C.Pen.Color := RGBToColor(54, 117, 202);
    C.Rectangle(LeftPos, TopPos, LeftPos + BarWidth - 8, LabelY);
    C.Brush.Style := bsClear;
    C.Font.Color := clBlack;
    C.TextOut(LeftPos, TopPos - 18, IntToStr(FSessionSummary.Models[I].Usage.TotalTokens));
    C.TextOut(LeftPos, LabelY + 4, Copy(FSessionSummary.Models[I].ModelName, 1, 12));
    C.Brush.Style := bsSolid;
  end;
end;

end.
