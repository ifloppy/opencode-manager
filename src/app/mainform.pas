unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, Spin, oc_config, oc_omo_config, oc_paths, oc_profiles,
  oc_presets, oc_http, oc_sessions, oc_i18n;

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
    LanguageLabel: TLabel;
    LanguageCombo: TComboBox;
    PageControl: TPageControl;
    Status: TStatusBar;

    ConfigPathEdit: TEdit;
    OMOPathEdit: TEdit;
    ConfigPathLabel, OMOPathLabel: TLabel;
    ConfigOpenButton, ConfigSaveButton, ReloadButton, ValidateButton: TButton;
    ValidationMemo: TMemo;
    RawMemo: TMemo;
    OMORawMemo: TMemo;
    OverviewProviderLabel, OverviewModelLabel, OverviewAgentLabel, OverviewMcpLabel: TLabel;
    OverviewPluginLabel, OverviewOMOLabel, OverviewTokenLabel: TLabel;
    OverviewSessionLabel: TLabel;
    OverviewStatPanels: array[0..7] of TPanel;

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
    ProfileNameLabel, ProfileRootLabel: TLabel;
    ProfileCreateButton, ProfileDeleteButton: TButton;

    OMOAgentList, OMOCategoryList: TListBox;
    OMOAgentIdEdit, OMOAgentModelEdit: TEdit;
    OMOAgentCategoryEdit, OMOAgentVariantEdit, OMOAgentThinkingEdit, OMOAgentReasoningEdit: TComboBox;
    OMOAgentPromptMemo: TMemo;
    OMOAgentIdLabel, OMOAgentModelLabel, OMOAgentCategoryLabel, OMOAgentVariantLabel: TLabel;
    OMOAgentTempLabel, OMOAgentThinkingLabel, OMOAgentReasoningLabel, OMOAgentPromptLabel: TLabel;
    OMOAgentTempEdit: TFloatSpinEdit;
    OMOAgentDisabledCheck: TCheckBox;
    OMOAgentSaveButton, OMOAgentDeleteButton: TButton;
    OMOCategoryIdEdit, OMOCategoryModelEdit, OMOCategoryDescEdit: TEdit;
    OMOCategoryVariantEdit, OMOCategoryThinkingEdit, OMOCategoryReasoningEdit: TComboBox;
    OMOCategoryPromptMemo: TMemo;
    OMOCategoryIdLabel, OMOCategoryModelLabel, OMOCategoryDescLabel, OMOCategoryVariantLabel: TLabel;
    OMOCategoryThinkingLabel, OMOCategoryReasoningLabel, OMOCategoryPromptLabel: TLabel;
    OMOCategoryDisabledCheck: TCheckBox;
    OMOCategorySaveButton, OMOCategoryDeleteButton: TButton;
    RawApplyButton: TButton;
    SessionPathLabel: TLabel;
    SessionPathEdit: TEdit;
    SessionModelDisplayLabel: TLabel;
    SessionModelDisplayEdit: TComboBox;
    SessionProjectList, SessionList, SessionModelList: TListView;
    SessionSummaryMemo: TMemo;
    SessionChart: TPaintBox;
    SessionRefreshButton: TButton;

    procedure BuildUi;
    procedure ApplyLanguage;
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
    function SelectedListViewText(List: TListView; SubItemIndex: Integer = -1): string;
    function SelectedModelId: string;
    function SessionModelCaption(const ModelId: string): string;
    function SessionModelDisplayName(const ModelId: string): string;
    function SelectedTools: string;
    procedure ApplyToolsToChecks(Agent: TJSONObject);
    function ObjectInSection(Root: TJSONObject; const Section, Id: string): TJSONObject;

    procedure OnOpenConfig(Sender: TObject);
    procedure OnFormResize(Sender: TObject);
    procedure OnNavButtonClick(Sender: TObject);
    procedure OnLanguageChange(Sender: TObject);
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
    procedure OnSessionModelDisplayChange(Sender: TObject);
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

const
  BUTTON_H = 36;
  BUTTON_GAP = 12;
  OMO_BUTTON_W = 180;
  CHART_TITLE_H = 38;

constructor TMainForm.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  Caption := UiText('OpenCode Configuration Manager', 'OpenCode 配置管理器');
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
  ApplyLanguage;
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
  Result.SetBounds(LeftPos, TopPos, WidthValue, BUTTON_H);
  Result.OnClick := Handler;
end;

function TMainForm.AddLabel(AParent: TWinControl; const ACaption: string; LeftPos, TopPos: Integer): TLabel;
begin
  Result := TLabel.Create(AParent);
  Result.Parent := AParent;
  Result.Caption := ACaption;
  Result.Hint := ACaption;
  Result.ShowHint := True;
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

  LanguageLabel := TLabel.Create(NavPanel);
  LanguageLabel.Parent := NavPanel;
  LanguageLabel.SetBounds(12, 660, 176, 22);
  LanguageCombo := TComboBox.Create(NavPanel);
  LanguageCombo.Parent := NavPanel;
  LanguageCombo.Style := csDropDownList;
  LanguageCombo.SetBounds(12, 684, 176, 28);
  LanguageCombo.Items.Add(UiLanguageName(ulEnglish));
  LanguageCombo.Items.Add(UiLanguageName(ulChinese));
  LanguageCombo.ItemIndex := Ord(CurrentUiLanguage);
  LanguageCombo.OnChange := @OnLanguageChange;

  PageControl := TPageControl.Create(Self);
  PageControl.Parent := Self;
  PageControl.Align := alClient;
  PageControl.TabPosition := tpTop;
  Status := TStatusBar.Create(Self);
  Status.Parent := Self;
  Status.Align := alBottom;

  Tab := AddTab('概览');
  for I := Low(OverviewStatPanels) to High(OverviewStatPanels) do
  begin
    OverviewStatPanels[I] := TPanel.Create(Tab);
    OverviewStatPanels[I].Parent := Tab;
    OverviewStatPanels[I].BevelOuter := bvLowered;
    OverviewStatPanels[I].Caption := '';
  end;
  OverviewProviderLabel := AddLabel(OverviewStatPanels[0], 'Provider: 0', 10, 10);
  OverviewModelLabel := AddLabel(OverviewStatPanels[1], 'Model: 0', 10, 10);
  OverviewAgentLabel := AddLabel(OverviewStatPanels[2], 'Agent: 0', 10, 10);
  OverviewMcpLabel := AddLabel(OverviewStatPanels[3], 'MCP: 0', 10, 10);
  OverviewPluginLabel := AddLabel(OverviewStatPanels[4], 'Plugin: 0', 10, 10);
  OverviewOMOLabel := AddLabel(OverviewStatPanels[5], 'OMO: 0 / 0', 10, 10);
  OverviewSessionLabel := AddLabel(OverviewStatPanels[6], '会话: 0', 10, 10);
  OverviewTokenLabel := AddLabel(OverviewStatPanels[7], '总 Token: 0', 10, 10);
  ConfigPathLabel := AddLabel(Tab, 'OpenCode 配置', 16, 122);
  ConfigPathEdit := AddEdit(Tab, 130, 118, 760);
  ConfigPathEdit.Anchors := [akLeft, akTop, akRight];
  ConfigOpenButton := AddButton(Tab, '打开', 900, 117, 124, @OnOpenConfig);
  ConfigSaveButton := AddButton(Tab, '保存全部', 990, 117, 124, @OnSaveConfig);
  OMOPathLabel := AddLabel(Tab, 'OMO 配置', 16, 160);
  OMOPathEdit := AddEdit(Tab, 130, 156, 760);
  OMOPathEdit.Anchors := [akLeft, akTop, akRight];
  ReloadButton := AddButton(Tab, '重新加载', 900, 155, 124, @OnReload);
  ValidateButton := AddButton(Tab, '校验', 1010, 155, 124, @OnValidate);
  ValidationMemo := TMemo.Create(Tab);
  ValidationMemo.Parent := Tab;
  ValidationMemo.SetBounds(16, 200, 1070, 460);
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
  OMOAgentPromptLabel := AddLabel(Tab, 'Agent 提示词追加 prompt_append', 740, 16);
  OMOAgentPromptLabel.Hint := '写入 OMO Agent 的 prompt_append 字段';
  OMOAgentPromptLabel.ShowHint := True;
  OMOAgentPromptMemo := TMemo.Create(Tab); OMOAgentPromptMemo.Parent := Tab; OMOAgentPromptMemo.SetBounds(740, 44, 390, 222); OMOAgentPromptMemo.ScrollBars := ssAutoBoth; OMOAgentPromptMemo.Hint := 'OMO Agent prompt_append：附加到该 Agent 的提示词'; OMOAgentPromptMemo.ShowHint := True;
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
  OMOCategoryPromptLabel := AddLabel(Tab, 'Category 提示词追加 prompt_append', 740, 330);
  OMOCategoryPromptLabel.Hint := '写入 OMO Category 的 prompt_append 字段';
  OMOCategoryPromptLabel.ShowHint := True;
  OMOCategoryPromptMemo := TMemo.Create(Tab); OMOCategoryPromptMemo.Parent := Tab; OMOCategoryPromptMemo.SetBounds(740, 358, 390, 222); OMOCategoryPromptMemo.ScrollBars := ssAutoBoth; OMOCategoryPromptMemo.Hint := 'OMO Category prompt_append：附加到该 Category 的提示词'; OMOCategoryPromptMemo.ShowHint := True;
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
  ProfileNameLabel := AddLabel(Tab, 'Profile 名称', 310, 20); ProfileNameEdit := AddEdit(Tab, 430, 16, 260);
  ProfileCreateButton := AddButton(Tab, '从当前配置创建', 430, 58, 160, @OnCreateProfile);
  ProfileDeleteButton := AddButton(Tab, '删除 Profile', 600, 58, 130, @OnDeleteProfile);
  ProfileRootLabel := AddLabel(Tab, 'Profile 根目录: ' + FProfiles.RootDir, 310, 110);

  Tab := AddTab('聊天记录');
  SessionPathLabel := AddLabel(Tab, '数据库文件', 16, 20); SessionPathEdit := AddEdit(Tab, 130, 16, 700); SessionPathEdit.Anchors := [akLeft, akTop, akRight];
  SessionRefreshButton := AddButton(Tab, '刷新统计', 850, 15, 120, @OnRefreshSessions);
  SessionModelDisplayLabel := AddLabel(Tab, '模型显示', 16, 58);
  SessionModelDisplayEdit := AddCombo(Tab, 130, 54, 150, ['模型 ID', '显示名']);
  SessionModelDisplayEdit.Style := csDropDownList;
  SessionModelDisplayEdit.ItemIndex := 0;
  SessionModelDisplayEdit.Hint := '切换聊天统计和图表中模型列的显示方式';
  SessionModelDisplayEdit.OnChange := @OnSessionModelDisplayChange;
  SessionPathEdit.Hint := 'OpenCode SQLite 数据库，通常位于 ~/.local/share/opencode/opencode.db';
  SessionProjectList := TListView.Create(Tab); SessionProjectList.Parent := Tab; SessionProjectList.SetBounds(16, 96, 300, 260); SessionProjectList.ViewStyle := vsReport; SessionProjectList.RowSelect := True; SessionProjectList.ReadOnly := True; SessionProjectList.OnClick := @OnSessionProjectSelect;
  SessionProjectList.Columns.Add.Caption := '项目'; SessionProjectList.Columns[0].Width := 160;
  SessionProjectList.Columns.Add.Caption := '会话'; SessionProjectList.Columns[1].Width := 60;
  SessionProjectList.Columns.Add.Caption := 'Token'; SessionProjectList.Columns[2].Width := 80;
  SessionList := TListView.Create(Tab); SessionList.Parent := Tab; SessionList.SetBounds(332, 96, 420, 260); SessionList.ViewStyle := vsReport; SessionList.RowSelect := True; SessionList.ReadOnly := True; SessionList.OnClick := @OnSessionSelect;
  SessionList.Columns.Add.Caption := '会话'; SessionList.Columns[0].Width := 170;
  SessionList.Columns.Add.Caption := '项目'; SessionList.Columns[1].Width := 120;
  SessionList.Columns.Add.Caption := '模型'; SessionList.Columns[2].Width := 130;
  SessionList.Columns.Add.Caption := 'Agent'; SessionList.Columns[3].Width := 90;
  SessionList.Columns.Add.Caption := 'Token'; SessionList.Columns[4].Width := 80;
  SessionList.Columns.Add.Caption := 'Session ID'; SessionList.Columns[5].Width := 0;
  SessionModelList := TListView.Create(Tab); SessionModelList.Parent := Tab; SessionModelList.SetBounds(16, 374, 736, 260); SessionModelList.ViewStyle := vsReport; SessionModelList.RowSelect := True; SessionModelList.ReadOnly := True;
  SessionModelList.Columns.Add.Caption := '模型'; SessionModelList.Columns[0].Width := 200;
  SessionModelList.Columns.Add.Caption := '总 Token'; SessionModelList.Columns[1].Width := 80;
  SessionModelList.Columns.Add.Caption := '输入'; SessionModelList.Columns[2].Width := 70;
  SessionModelList.Columns.Add.Caption := '输出'; SessionModelList.Columns[3].Width := 70;
  SessionModelList.Columns.Add.Caption := 'Reasoning'; SessionModelList.Columns[4].Width := 80;
  SessionModelList.Columns.Add.Caption := '缓存读'; SessionModelList.Columns[5].Width := 70;
  SessionModelList.Columns.Add.Caption := '缓存写'; SessionModelList.Columns[6].Width := 70;
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

procedure TMainForm.ApplyLanguage;
var
  I: Integer;
  NavCaptions: array[0..7] of string;
begin
  Caption := UiText('OpenCode Configuration Manager', 'OpenCode 配置管理器');
  LanguageLabel.Caption := UiText('Language', '语言');
  if LanguageCombo.ItemIndex <> Ord(CurrentUiLanguage) then
    LanguageCombo.ItemIndex := Ord(CurrentUiLanguage);

  NavCaptions[0] := UiText('Overview', '概览');
  NavCaptions[1] := UiText('Provider / Model', 'Provider / Model');
  NavCaptions[2] := UiText('OpenCode Agent', 'OpenCode Agent');
  NavCaptions[3] := UiText('OMO Agents / Categories', 'OMO Agents / Categories');
  NavCaptions[4] := UiText('MCP / Plugin', 'MCP / Plugin');
  NavCaptions[5] := UiText('Profile', 'Profile');
  NavCaptions[6] := UiText('Chat Usage', '聊天记录');
  NavCaptions[7] := UiText('Raw JSON', '原始 JSON');
  for I := 0 to PageControl.PageCount - 1 do
    if I <= High(NavCaptions) then
      PageControl.Pages[I].Caption := NavCaptions[I];
  for I := 0 to NavPanel.ControlCount - 1 do
    if (NavPanel.Controls[I] is TButton) and (TButton(NavPanel.Controls[I]).Tag <= High(NavCaptions)) then
      TButton(NavPanel.Controls[I]).Caption := NavCaptions[TButton(NavPanel.Controls[I]).Tag];

  ConfigPathLabel.Caption := UiText('OpenCode config', 'OpenCode 配置');
  ConfigOpenButton.Caption := UiText('Open', '打开');
  ConfigSaveButton.Caption := UiText('Save all', '保存全部');
  OMOPathLabel.Caption := UiText('OMO config', 'OMO 配置');
  ReloadButton.Caption := UiText('Reload', '重新加载');
  ValidateButton.Caption := UiText('Validate', '校验');
  ValidationMemo.Hint := UiText('Config paths, validation results, and structure issues', '配置路径、校验结果和结构问题');

  ProviderList.Hint := UiText('Provider list', 'Provider 列表');
  ProviderNameLabel.Caption := UiText('Display name', '显示名');
  ProviderSaveButton.Caption := UiText('Save Provider', '保存 Provider');
  ProviderDeleteButton.Caption := UiText('Delete Provider', '删除 Provider');
  ModelList.Hint := UiText('Model list: select one to show the full name and key in the status bar', '模型列表：选择后状态栏显示完整名称和 key');
  ModelNameLabel.Caption := UiText('Model display name', '模型显示名');
  ModelSaveButton.Caption := UiText('Save Model', '保存 Model');
  ModelDeleteButton.Caption := UiText('Delete Model', '删除 Model');
  ModelTestButton.Caption := UiText('Test connectivity', '测试连通性');

  AgentDescriptionLabel.Caption := UiText('Description', '描述');
  AgentModeLabel.Caption := UiText('Mode', '模式');
  AgentModelLabel.Caption := UiText('Model', '模型');
  AgentTempLabel.Caption := UiText('Temperature', '温度');
  AgentDisabledCheck.Caption := UiText('Disabled', '禁用');
  AgentHiddenCheck.Caption := UiText('Hidden', '隐藏');
  AgentColorLabel.Caption := UiText('Color', '颜色');
  AgentToolsLabel.Caption := UiText('Tools', '工具');
  AgentSaveButton.Caption := UiText('Save Agent', '保存 Agent');
  AgentDeleteButton.Caption := UiText('Delete Agent', '删除 Agent');

  OMOAgentList.Hint := UiText('OMO Agent list. Built-in items can be edited or disabled, but not deleted.', 'OMO Agent 列表，内置项可编辑或禁用但不能删除');
  OMOAgentModelLabel.Caption := UiText('Model', '模型');
  OMOAgentTempLabel.Caption := UiText('Temperature', '温度');
  OMOAgentDisabledCheck.Caption := UiText('Disabled', '禁用');
  OMOAgentPromptLabel.Caption := UiText('Agent prompt_append', 'Agent 提示词追加 prompt_append');
  OMOAgentPromptLabel.Hint := UiText('Writes the OMO Agent prompt_append field', '写入 OMO Agent 的 prompt_append 字段');
  OMOAgentPromptMemo.Hint := UiText('OMO Agent prompt_append: appended to this Agent prompt', 'OMO Agent prompt_append：附加到该 Agent 的提示词');
  OMOAgentSaveButton.Caption := UiText('Save OMO Agent', '保存 OMO Agent');
  OMOAgentDeleteButton.Caption := UiText('Delete OMO Agent', '删除 OMO Agent');
  OMOCategoryList.Hint := UiText('OMO Category list', 'OMO Category 列表');
  OMOCategoryModelLabel.Caption := UiText('Model', '模型');
  OMOCategoryDescLabel.Caption := UiText('Description', '描述');
  OMOCategoryDisabledCheck.Caption := UiText('Disabled', '禁用');
  OMOCategoryPromptLabel.Caption := UiText('Category prompt_append', 'Category 提示词追加 prompt_append');
  OMOCategoryPromptLabel.Hint := UiText('Writes the OMO Category prompt_append field', '写入 OMO Category 的 prompt_append 字段');
  OMOCategoryPromptMemo.Hint := UiText('OMO Category prompt_append: appended to this Category prompt', 'OMO Category prompt_append：附加到该 Category 的提示词');
  OMOCategorySaveButton.Caption := UiText('Save Category', '保存 Category');
  OMOCategoryDeleteButton.Caption := UiText('Delete Category', '删除 Category');

  McpList.Hint := UiText('MCP list', 'MCP 列表');
  McpTypeLabel.Caption := UiText('Type', '类型');
  McpTargetLabel.Caption := UiText('Command or URL', '命令或 URL');
  McpEnabledCheck.Caption := UiText('Enabled', '启用');
  McpNewButton.Caption := UiText('New MCP', '新增 MCP');
  McpSaveButton.Caption := UiText('Save MCP', '保存 MCP');
  McpDeleteButton.Caption := UiText('Delete MCP', '删除 MCP');
  PluginList.Hint := UiText('Plugin package list', 'Plugin 包列表');
  PluginNameLabel.Caption := UiText('Plugin package', 'Plugin 包名');
  PluginNewButton.Caption := UiText('New Plugin', '新增 Plugin');
  PluginSaveButton.Caption := UiText('Save Plugin', '保存 Plugin');
  PluginDeleteButton.Caption := UiText('Delete Plugin', '删除 Plugin');

  ProfileNameLabel.Caption := UiText('Profile name', 'Profile 名称');
  ProfileCreateButton.Caption := UiText('Create from current config', '从当前配置创建');
  ProfileDeleteButton.Caption := UiText('Delete Profile', '删除 Profile');
  ProfileRootLabel.Caption := UiText('Profile root: ', 'Profile 根目录: ') + FProfiles.RootDir;

  SessionPathLabel.Caption := UiText('Database file', '数据库文件');
  SessionRefreshButton.Caption := UiText('Refresh stats', '刷新统计');
  SessionModelDisplayLabel.Caption := UiText('Model display', '模型显示');
  SessionModelDisplayEdit.Items[0] := UiText('Model ID', '模型 ID');
  SessionModelDisplayEdit.Items[1] := UiText('Display name', '显示名');
  SessionModelDisplayEdit.Hint := UiText('Switch how model columns are shown in usage statistics and charts', '切换聊天统计和图表中模型列的显示方式');
  SessionPathEdit.Hint := UiText('OpenCode SQLite database, usually at ~/.local/share/opencode/opencode.db', 'OpenCode SQLite 数据库，通常位于 ~/.local/share/opencode/opencode.db');
  SessionProjectList.Columns[0].Caption := UiText('Project', '项目');
  SessionProjectList.Columns[1].Caption := UiText('Sessions', '会话');
  SessionProjectList.Columns[2].Caption := 'Token';
  SessionList.Columns[0].Caption := UiText('Session', '会话');
  SessionList.Columns[1].Caption := UiText('Project', '项目');
  SessionList.Columns[2].Caption := UiText('Model', '模型');
  SessionList.Columns[3].Caption := 'Agent';
  SessionList.Columns[4].Caption := 'Token';
  SessionList.Columns[5].Caption := 'Session ID';
  SessionModelList.Columns[0].Caption := UiText('Model', '模型');
  SessionModelList.Columns[1].Caption := UiText('Total Token', '总 Token');
  SessionModelList.Columns[2].Caption := UiText('Input', '输入');
  SessionModelList.Columns[3].Caption := UiText('Output', '输出');
  SessionModelList.Columns[4].Caption := 'Reasoning';
  SessionModelList.Columns[5].Caption := UiText('Cache read', '缓存读');
  SessionModelList.Columns[6].Caption := UiText('Cache write', '缓存写');
  RawApplyButton.Caption := UiText('Apply raw JSON', '从原始 JSON 应用');

  RefreshValidation;
  PopulateSessionLists;
  RefreshOverviewStats;
  if Assigned(SessionChart) then
    SessionChart.Invalidate;
end;

procedure TMainForm.AdjustResponsiveLayout;
var
  W, H, ListGap, ListHeight, FieldX, FieldW, RightEdge, RawWidth: Integer;
  ButtonTop, PromptTop, PromptH, RightX, RightW, SectionH, FormW, ModelTop, PluginTop: Integer;
  ToolCols, ToolW, ToolX, ToolY, I, StatW, StatTop, StatsPerRow: Integer;
begin
  if Assigned(ValidationMemo) then
  begin
    W := ValidationMemo.Parent.ClientWidth;
    H := ValidationMemo.Parent.ClientHeight;
    StatsPerRow := 4;
    StatW := (W - 16 * 2 - 12 * (StatsPerRow - 1)) div StatsPerRow;
    if StatW < 150 then
    begin
      StatsPerRow := 2;
      StatW := (W - 16 * 2 - 12) div 2;
    end;
    if StatW < 130 then
      StatW := 130;
    for I := Low(OverviewStatPanels) to High(OverviewStatPanels) do
    begin
      StatTop := 16 + (I div StatsPerRow) * 56;
      OverviewStatPanels[I].SetBounds(16 + (I mod StatsPerRow) * (StatW + 12), StatTop, StatW, 44);
    end;
    OverviewProviderLabel.SetBounds(10, 10, StatW - 20, 24);
    OverviewModelLabel.SetBounds(10, 10, StatW - 20, 24);
    OverviewAgentLabel.SetBounds(10, 10, StatW - 20, 24);
    OverviewMcpLabel.SetBounds(10, 10, StatW - 20, 24);
    OverviewPluginLabel.SetBounds(10, 10, StatW - 20, 24);
    OverviewOMOLabel.SetBounds(10, 10, StatW - 20, 24);
    OverviewSessionLabel.SetBounds(10, 10, StatW - 20, 24);
    OverviewTokenLabel.SetBounds(10, 10, StatW - 20, 24);
    ConfigPathLabel.SetBounds(16, 132, 110, 24);
    ConfigPathEdit.SetBounds(130, 128, W - 426, 28);
    ConfigOpenButton.SetBounds(W - 280, 127, 124, BUTTON_H);
    ConfigSaveButton.SetBounds(W - 144, 127, 124, BUTTON_H);
    OMOPathLabel.SetBounds(16, 170, 110, 24);
    OMOPathEdit.SetBounds(130, 166, W - 426, 28);
    ReloadButton.SetBounds(W - 280, 165, 124, BUTTON_H);
    ValidateButton.SetBounds(W - 144, 165, 124, BUTTON_H);
    ValidationMemo.SetBounds(16, 206, W - 32, H - 222);
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
    ProviderSaveButton.SetBounds(FieldX, 210, 130, BUTTON_H);
    ProviderDeleteButton.SetBounds(FieldX + 150, 210, 130, BUTTON_H);
    ModelIdLabel.SetBounds(250, ModelTop + 4, 120, 24);
    ModelIdEdit.SetBounds(FieldX, ModelTop, FieldW, 28);
    ModelNameLabel.SetBounds(250, ModelTop + 42, 120, 24);
    ModelNameEdit.SetBounds(FieldX, ModelTop + 38, FieldW, 28);
    ModelSaveButton.SetBounds(FieldX, ModelTop + 80, 130, BUTTON_H);
    ModelDeleteButton.SetBounds(FieldX + 150, ModelTop + 80, 130, BUTTON_H);
    ModelTestButton.SetBounds(FieldX + 300, ModelTop + 80, 140, BUTTON_H);
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
    AgentSaveButton.SetBounds(FieldX, ButtonTop, 130, BUTTON_H);
    AgentDeleteButton.SetBounds(FieldX + 150, ButtonTop, 130, BUTTON_H);
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
    RawApplyButton.SetBounds(16, H - BUTTON_H - 14, 190, BUTTON_H);
  end;

  if Assigned(OMOAgentPromptMemo) then
  begin
    W := OMOAgentPromptMemo.Parent.ClientWidth;
    H := OMOAgentPromptMemo.Parent.ClientHeight;
    OMOAgentList.SetBounds(16, 16, 210, 304);
    OMOCategoryList.SetBounds(16, 340, 210, H - 356);
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
    OMOAgentThinkingEdit.SetBounds(365, 206, 160, 28);
    OMOAgentReasoningLabel.SetBounds(245, 248, 120, 24);
    OMOAgentReasoningEdit.SetBounds(365, 244, 160, 28);
    OMOAgentSaveButton.SetBounds(365, 284, OMO_BUTTON_W, BUTTON_H);
    OMOAgentDeleteButton.SetBounds(365 + OMO_BUTTON_W + BUTTON_GAP, 284, OMO_BUTTON_W, BUTTON_H);
    OMOCategoryIdLabel.SetBounds(245, 344, 120, 24);
    OMOCategoryIdEdit.SetBounds(365, 340, FormW, 28);
    OMOCategoryModelLabel.SetBounds(245, 382, 120, 24);
    OMOCategoryModelEdit.SetBounds(365, 378, FormW, 28);
    OMOCategoryDescLabel.SetBounds(245, 420, 120, 24);
    OMOCategoryDescEdit.SetBounds(365, 416, FormW, 28);
    OMOCategoryVariantLabel.SetBounds(245, 458, 120, 24);
    OMOCategoryVariantEdit.SetBounds(365, 454, FormW, 28);
    OMOCategoryDisabledCheck.SetBounds(365, 492, 80, 24);
    OMOCategoryThinkingLabel.SetBounds(245, 530, 120, 24);
    OMOCategoryThinkingEdit.SetBounds(365, 526, 160, 28);
    OMOCategoryReasoningLabel.SetBounds(245, 568, 120, 24);
    OMOCategoryReasoningEdit.SetBounds(365, 564, 160, 28);
    OMOCategorySaveButton.SetBounds(365, 604, OMO_BUTTON_W, BUTTON_H);
    OMOCategoryDeleteButton.SetBounds(365 + OMO_BUTTON_W + BUTTON_GAP, 604, OMO_BUTTON_W, BUTTON_H);
    OMOAgentPromptLabel.SetBounds(RightX, 16, RightW, 24);
    OMOAgentPromptMemo.SetBounds(RightX, 44, RightW, 252);
    OMOCategoryPromptLabel.SetBounds(RightX, 340, RightW, 24);
    OMOCategoryPromptMemo.SetBounds(RightX, 368, RightW, H - 384);
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
    McpNewButton.SetBounds(FieldX, 170, 130, BUTTON_H);
    McpSaveButton.SetBounds(FieldX + 150, 170, 130, BUTTON_H);
    McpDeleteButton.SetBounds(FieldX + 300, 170, 130, BUTTON_H);
    PluginNameLabel.SetBounds(260, PluginTop + 4, 120, 24);
    PluginNameEdit.SetBounds(FieldX, PluginTop, FieldW, 28);
    PluginNewButton.SetBounds(FieldX, PluginTop + 40, 130, BUTTON_H);
    PluginSaveButton.SetBounds(FieldX + 150, PluginTop + 40, 130, BUTTON_H);
    PluginDeleteButton.SetBounds(FieldX + 300, PluginTop + 40, 130, BUTTON_H);
  end;

  if Assigned(SessionProjectList) then
  begin
    W := SessionProjectList.Parent.ClientWidth;
    H := SessionProjectList.Parent.ClientHeight;
    SessionPathLabel.SetBounds(16, 20, 110, 24);
    SessionPathEdit.SetBounds(130, 16, W - 280, 28);
    SessionRefreshButton.SetBounds(W - 144, 15, 128, BUTTON_H);
    SessionModelDisplayLabel.SetBounds(16, 58, 110, 24);
    SessionModelDisplayEdit.SetBounds(130, 54, 150, 28);
    SectionH := (H - 142) div 2;
    if SectionH < 180 then
      SectionH := 180;
    SessionProjectList.SetBounds(16, 96, 300, SectionH);
    SessionList.SetBounds(332, 96, W - 860, SectionH);
    if SessionList.Width < 360 then
      SessionList.Width := 360;
    SessionModelList.SetBounds(16, 116 + SectionH, SessionList.Left + SessionList.Width - 16, H - SectionH - 132);
    SessionSummaryMemo.SetBounds(SessionList.Left + SessionList.Width + 16, 96, W - SessionList.Left - SessionList.Width - 32, 180);
    SessionChart.SetBounds(SessionSummaryMemo.Left, 292, SessionSummaryMemo.Width, H - 308);
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
  Status.SimpleText := UiText('Loaded: ', '已加载: ') + ConfigPathEdit.Text;
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

function CompactInt(Value: Int64): string;
var
  AbsValue: Int64;
  Scaled: Double;
  Suffix: string;
begin
  AbsValue := Abs(Value);
  if AbsValue >= 1000000000 then
  begin
    Scaled := Value / 1000000000;
    Suffix := 'B';
  end
  else if AbsValue >= 1000000 then
  begin
    Scaled := Value / 1000000;
    Suffix := 'M';
  end
  else if AbsValue >= 1000 then
  begin
    Scaled := Value / 1000;
    Suffix := 'K';
  end
  else
    Exit(IntToStr(Value));
  Result := FormatFloat('0.##', Scaled) + Suffix;
end;

function CompactDetail(Value: Int64): string;
begin
  Result := CompactInt(Value);
  if Result <> IntToStr(Value) then
    Result := Result + ' (' + IntToStr(Value) + ')';
end;

function ShortChartLabel(const Text: string): string;
var
  SlashPos: Integer;
begin
  Result := Text;
  SlashPos := Pos('/', Result);
  if SlashPos > 0 then
    Result := Copy(Result, SlashPos + 1, MaxInt);
  if Length(Result) > 18 then
    Result := Copy(Result, 1, 17) + '..';
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
  OverviewSessionLabel.Caption := UiText('Sessions: ', '会话: ') + IntToStr(FSessionSummary.SessionCount);
  OverviewTokenLabel.Caption := 'Token: ' + CompactInt(FSessionSummary.Total.TotalTokens);
  OverviewTokenLabel.Hint := UiText('Total Token: ', '总 Token: ') + CompactDetail(FSessionSummary.Total.TotalTokens) +
    UiText(', input: ', '，输入: ') + CompactDetail(FSessionSummary.Total.InputTokens) +
    UiText(', output: ', '，输出: ') + CompactDetail(FSessionSummary.Total.OutputTokens) +
    UiText(', reasoning: ', '，Reasoning: ') + CompactDetail(FSessionSummary.Total.ReasoningTokens) +
    UiText(', cache read: ', '，缓存读: ') + CompactDetail(FSessionSummary.Total.CacheReadTokens) +
    UiText(', cache write: ', '，缓存写: ') + CompactDetail(FSessionSummary.Total.CacheWriteTokens);
end;

procedure TMainForm.RefreshSessionSummary;
begin
  if not Assigned(SessionPathEdit) then
    Exit;
  if SessionPathEdit.Text = '' then
    SessionPathEdit.Text := DiscoverOpenCodeDatabasePath;
  if LowerCase(ExtractFileExt(SessionPathEdit.Text)) = '.db' then
    FSessionSummary := ScanOpenCodeDatabase(SessionPathEdit.Text)
  else
    FSessionSummary := ScanOpenCodeSessions(SessionPathEdit.Text);
  PopulateSessionLists;
  if Assigned(SessionChart) then
    SessionChart.Invalidate;
end;

procedure TMainForm.PopulateSessionLists;
var
  I: Integer;
  Item: TListItem;
begin
  if not Assigned(SessionProjectList) then
    Exit;
  SessionProjectList.Clear;
  SessionList.Clear;
  SessionModelList.Clear;
  for I := 0 to High(FSessionSummary.Projects) do
  begin
    Item := SessionProjectList.Items.Add;
    Item.Caption := FSessionSummary.Projects[I].ProjectName;
    Item.SubItems.Add(IntToStr(FSessionSummary.Projects[I].SessionCount));
    Item.SubItems.Add(CompactInt(FSessionSummary.Projects[I].Usage.TotalTokens));
  end;
  for I := 0 to High(FSessionSummary.Sessions) do
  begin
    Item := SessionList.Items.Add;
    Item.Caption := FSessionSummary.Sessions[I].SessionName;
    Item.SubItems.Add(FSessionSummary.Sessions[I].ProjectName);
    Item.SubItems.Add(SessionModelCaption(FSessionSummary.Sessions[I].ModelName));
    Item.SubItems.Add(FSessionSummary.Sessions[I].AgentName);
    Item.SubItems.Add(CompactInt(FSessionSummary.Sessions[I].Usage.TotalTokens));
    Item.SubItems.Add(FSessionSummary.Sessions[I].SessionId);
  end;
  for I := 0 to High(FSessionSummary.Models) do
  begin
    Item := SessionModelList.Items.Add;
    Item.Caption := SessionModelCaption(FSessionSummary.Models[I].ModelName);
    Item.SubItems.Add(CompactInt(FSessionSummary.Models[I].Usage.TotalTokens));
    Item.SubItems.Add(CompactInt(FSessionSummary.Models[I].Usage.InputTokens));
    Item.SubItems.Add(CompactInt(FSessionSummary.Models[I].Usage.OutputTokens));
    Item.SubItems.Add(CompactInt(FSessionSummary.Models[I].Usage.ReasoningTokens));
    Item.SubItems.Add(CompactInt(FSessionSummary.Models[I].Usage.CacheReadTokens));
    Item.SubItems.Add(CompactInt(FSessionSummary.Models[I].Usage.CacheWriteTokens));
  end;
  SessionSummaryMemo.Clear;
  SessionSummaryMemo.Lines.Add(UiText('Projects: ', '项目数: ') + IntToStr(FSessionSummary.ProjectCount));
  SessionSummaryMemo.Lines.Add(UiText('Sessions: ', '会话数: ') + IntToStr(FSessionSummary.SessionCount));
  SessionSummaryMemo.Lines.Add(UiText('Total Token: ', '总 Token: ') + CompactDetail(FSessionSummary.Total.TotalTokens));
  SessionSummaryMemo.Lines.Add(UiText('Input Token: ', '输入 Token: ') + CompactDetail(FSessionSummary.Total.InputTokens));
  SessionSummaryMemo.Lines.Add(UiText('Output Token: ', '输出 Token: ') + CompactDetail(FSessionSummary.Total.OutputTokens));
  SessionSummaryMemo.Lines.Add('Reasoning Token: ' + CompactDetail(FSessionSummary.Total.ReasoningTokens));
  SessionSummaryMemo.Lines.Add(UiText('Cache read/write Token: ', '缓存读/写 Token: ') + CompactDetail(FSessionSummary.Total.CacheReadTokens) + ' / ' + CompactDetail(FSessionSummary.Total.CacheWriteTokens));
  SessionSummaryMemo.Lines.Add(UiText('Database: ', '数据库: ') + FSessionSummary.RootDir);
end;

procedure TMainForm.RefreshValidation;
var
  Issues: TValidationIssueArray;
  Issue: TValidationIssue;
begin
  ValidationMemo.Clear;
  ValidationMemo.Lines.Add(UiText('OpenCode config: ', 'OpenCode 配置: ') + ConfigPathEdit.Text);
  Issues := FConfig.Validate;
  for Issue in Issues do
    ValidationMemo.Lines.Add('[' + Issue.Severity + '] ' + Issue.Message);
  ValidationMemo.Lines.Add('');
  ValidationMemo.Lines.Add(UiText('Oh My OpenAgent config: ', 'Oh My OpenAgent 配置: ') + OMOPathEdit.Text);
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

function TMainForm.SelectedListViewText(List: TListView; SubItemIndex: Integer): string;
begin
  Result := '';
  if not Assigned(List) or not Assigned(List.Selected) then
    Exit;
  if SubItemIndex < 0 then
    Result := List.Selected.Caption
  else if SubItemIndex < List.Selected.SubItems.Count then
    Result := List.Selected.SubItems[SubItemIndex];
end;

function TMainForm.SelectedModelId: string;
begin
  if (ModelList.ItemIndex >= 0) and (ModelList.ItemIndex < FModelListKeys.Count) then
    Result := FModelListKeys[ModelList.ItemIndex]
  else
    Result := ModelIdEdit.Text;
end;

function TMainForm.SessionModelDisplayName(const ModelId: string): string;
var
  ProviderId, RawModelId: string;
  SlashPos: Integer;
  Provider, Models: TJSONObject;
  ModelObj: TJSONObject;
begin
  Result := '';
  RawModelId := ModelId;
  ProviderId := '';
  SlashPos := Pos('/', ModelId);
  if SlashPos > 0 then
  begin
    ProviderId := Copy(ModelId, 1, SlashPos - 1);
    RawModelId := Copy(ModelId, SlashPos + 1, MaxInt);
  end;

  if ProviderId <> '' then
  begin
    Provider := ObjectInSection(FConfig.Data, 'provider', ProviderId);
    if Assigned(Provider) and (Provider.Find('models') is TJSONObject) then
    begin
      Models := TJSONObject(Provider.Find('models'));
      if Models.Find(RawModelId) is TJSONObject then
      begin
        ModelObj := TJSONObject(Models.Find(RawModelId));
        Result := ModelObj.Get('name', '');
      end;
    end;
  end;
end;

function TMainForm.SessionModelCaption(const ModelId: string): string;
var
  DisplayName: string;
begin
  Result := ModelId;
  if Assigned(SessionModelDisplayEdit) and (SessionModelDisplayEdit.ItemIndex = 1) then
  begin
    DisplayName := SessionModelDisplayName(ModelId);
    if DisplayName <> '' then
      Result := DisplayName;
  end;
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
    D.Filter := UiText('OpenCode JSON|*.json;*.jsonc|All files|*.*', 'OpenCode JSON|*.json;*.jsonc|所有文件|*.*');
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

procedure TMainForm.OnLanguageChange(Sender: TObject);
begin
  if not Assigned(LanguageCombo) then
    Exit;
  if LanguageCombo.ItemIndex = Ord(ulChinese) then
    CurrentUiLanguage := ulChinese
  else
    CurrentUiLanguage := ulEnglish;
  ApplyLanguage;
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
  ShowMessage(UiText('Configuration saved. A backup was created in the backups directory.', '已保存配置，并在 backups 目录创建备份。'));
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
    ModelList.Hint := UiText('Model list: select one to show the full name and key in the status bar. Current items: ', '模型列表：选择后状态栏显示完整名称和 key。当前 ') + IntToStr(ModelList.Items.Count) + UiText('.', ' 项。');
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
    Status.SimpleText := UiText('Model: ', '模型: ') + ModelNameEdit.Text + ' / ' + ModelIdEdit.Text
  else
    Status.SimpleText := UiText('Model: ', '模型: ') + ModelIdEdit.Text;
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
    Status.SimpleText := UiText('Model connectivity test succeeded: HTTP ', '模型连通性测试成功: HTTP ') + IntToStr(R.StatusCode) + ', ' + IntToStr(R.ResponseTimeMs) + 'ms';
    ShowMessage(Status.SimpleText);
  end
  else
  begin
    Status.SimpleText := UiText('Model connectivity test failed: ', '模型连通性测试失败: ') + R.ErrorMessage;
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
    ShowMessage(UiText('Built-in Agents cannot be deleted. They can only be edited or disabled.', '内置 Agent 不能删除，只能编辑或禁用。'));
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
  Status.SimpleText := UiText('Enter the new MCP ID, type, and command or URL, then click Save MCP.', '请输入新的 MCP ID、类型和命令或 URL，然后点击保存 MCP。');
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
  PluginNameEdit.Hint := UiText('Enter a new Plugin package name, such as an npm package or local plugin path', '输入新的 Plugin 包名，例如 npm 包名或本地插件路径');
  Status.SimpleText := UiText('Enter the new Plugin package name, then click Save Plugin.', '请输入新的 Plugin 包名，然后点击保存 Plugin。');
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
    ShowMessage(UiText('Built-in OMO Agents cannot be deleted. They can only be edited or disabled.', '内置 OMO Agent 不能删除，只能编辑或禁用。'));
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
  RefreshSessionSummary;
  RefreshOverviewStats;
end;

procedure TMainForm.OnSessionModelDisplayChange(Sender: TObject);
begin
  PopulateSessionLists;
  if Assigned(SessionChart) then
    SessionChart.Invalidate;
end;

procedure TMainForm.OnSessionProjectSelect(Sender: TObject);
var
  I: Integer;
  ProjectName: string;
  Item: TListItem;
begin
  ProjectName := SelectedListViewText(SessionProjectList);
  SessionList.Clear;
  for I := 0 to High(FSessionSummary.Sessions) do
    if (ProjectName = '') or (FSessionSummary.Sessions[I].ProjectName = ProjectName) then
    begin
      Item := SessionList.Items.Add;
      Item.Caption := FSessionSummary.Sessions[I].SessionName;
      Item.SubItems.Add(FSessionSummary.Sessions[I].ProjectName);
      Item.SubItems.Add(SessionModelCaption(FSessionSummary.Sessions[I].ModelName));
      Item.SubItems.Add(FSessionSummary.Sessions[I].AgentName);
      Item.SubItems.Add(CompactInt(FSessionSummary.Sessions[I].Usage.TotalTokens));
      Item.SubItems.Add(FSessionSummary.Sessions[I].SessionId);
    end;
end;

procedure TMainForm.OnSessionSelect(Sender: TObject);
var
  I: Integer;
  SessionId: string;
begin
  SessionId := SelectedListViewText(SessionList, 4);
  if SessionId = '' then
    SessionId := SelectedListViewText(SessionList);
  for I := 0 to High(FSessionSummary.Sessions) do
    if (SessionId = FSessionSummary.Sessions[I].SessionId) or
       ((FSessionSummary.Sessions[I].SessionId = '') and (SessionId = FSessionSummary.Sessions[I].SessionName)) then
    begin
      SessionSummaryMemo.Clear;
      SessionSummaryMemo.Lines.Add(UiText('Project: ', '项目: ') + FSessionSummary.Sessions[I].ProjectName);
      if FSessionSummary.Sessions[I].ProjectPath <> '' then
        SessionSummaryMemo.Lines.Add(UiText('Directory: ', '目录: ') + FSessionSummary.Sessions[I].ProjectPath);
      SessionSummaryMemo.Lines.Add(UiText('Session: ', '会话: ') + FSessionSummary.Sessions[I].SessionName);
      SessionSummaryMemo.Lines.Add(UiText('Model: ', '模型: ') + SessionModelCaption(FSessionSummary.Sessions[I].ModelName));
      if SessionModelCaption(FSessionSummary.Sessions[I].ModelName) <> FSessionSummary.Sessions[I].ModelName then
        SessionSummaryMemo.Lines.Add(UiText('Model ID: ', '模型 ID: ') + FSessionSummary.Sessions[I].ModelName);
      if FSessionSummary.Sessions[I].AgentName <> '' then
        SessionSummaryMemo.Lines.Add('Agent: ' + FSessionSummary.Sessions[I].AgentName);
      SessionSummaryMemo.Lines.Add(UiText('Total Token: ', '总 Token: ') + CompactDetail(FSessionSummary.Sessions[I].Usage.TotalTokens));
      SessionSummaryMemo.Lines.Add(UiText('Input Token: ', '输入 Token: ') + CompactDetail(FSessionSummary.Sessions[I].Usage.InputTokens));
      SessionSummaryMemo.Lines.Add(UiText('Output Token: ', '输出 Token: ') + CompactDetail(FSessionSummary.Sessions[I].Usage.OutputTokens));
      SessionSummaryMemo.Lines.Add('Reasoning Token: ' + CompactDetail(FSessionSummary.Sessions[I].Usage.ReasoningTokens));
      SessionSummaryMemo.Lines.Add(UiText('Cache read/write Token: ', '缓存读/写 Token: ') + CompactDetail(FSessionSummary.Sessions[I].Usage.CacheReadTokens) + ' / ' + CompactDetail(FSessionSummary.Sessions[I].Usage.CacheWriteTokens));
      SessionSummaryMemo.Lines.Add('Session ID: ' + FSessionSummary.Sessions[I].SessionId);
      Exit;
    end;
end;

procedure TMainForm.OnTokenChartPaint(Sender: TObject);
var
  C: TCanvas;
  I, J, TopPos, RowH, BarLeft, BarTop, BarW, BarMaxW, LabelW, ValueW: Integer;
  ChartCount, FitCount, BestIndex: Integer;
  MaxTokens, BestTokens, Tokens: Int64;
  ChartW, ChartH: Integer;
  Used: array of Boolean;
  ChartIndexes: array of Integer;
  ValueText, ModelText: string;
begin
  C := SessionChart.Canvas;
  ChartW := SessionChart.Width;
  ChartH := SessionChart.Height;
  C.Brush.Color := clWhite;
  C.FillRect(0, 0, ChartW, ChartH);
  C.Pen.Color := clGray;
  C.Rectangle(0, 0, ChartW, ChartH);
  C.Font.Color := clBlack;
  if Length(FSessionSummary.Models) = 0 then
  begin
    C.TextOut(12, 14, UiText('Token usage by model', '按模型 Token 用量'));
    C.TextOut(12, CHART_TITLE_H + 4, UiText('No session Token data found for statistics.', '未找到可统计的会话 Token 数据'));
    Exit;
  end;

  RowH := 24;
  FitCount := (ChartH - CHART_TITLE_H - 16) div RowH;
  if FitCount < 1 then
    FitCount := 1;
  ChartCount := Length(FSessionSummary.Models);
  if ChartCount > 20 then
    ChartCount := 20;
  if ChartCount > FitCount then
    ChartCount := FitCount;
  C.TextOut(12, 14, UiText('Token usage by model Top ', '按模型 Token 用量 Top ') + IntToStr(ChartCount));

  SetLength(Used, Length(FSessionSummary.Models));
  SetLength(ChartIndexes, ChartCount);
  for I := 0 to ChartCount - 1 do
  begin
    BestIndex := -1;
    BestTokens := -1;
    for J := 0 to High(FSessionSummary.Models) do
      if (not Used[J]) and (FSessionSummary.Models[J].Usage.TotalTokens > BestTokens) then
      begin
        BestIndex := J;
        BestTokens := FSessionSummary.Models[J].Usage.TotalTokens;
      end;
    if BestIndex < 0 then
      BestIndex := I;
    ChartIndexes[I] := BestIndex;
    Used[BestIndex] := True;
  end;

  MaxTokens := 1;
  for I := 0 to ChartCount - 1 do
    if FSessionSummary.Models[ChartIndexes[I]].Usage.TotalTokens > MaxTokens then
      MaxTokens := FSessionSummary.Models[ChartIndexes[I]].Usage.TotalTokens;

  ValueW := 82;
  LabelW := ChartW div 3;
  if LabelW < 118 then
    LabelW := 118;
  if LabelW > 220 then
    LabelW := 220;
  BarLeft := 16 + LabelW + 10;
  BarMaxW := ChartW - BarLeft - ValueW - 22;
  if BarMaxW < 40 then
    BarMaxW := 40;

  for I := 0 to ChartCount - 1 do
  begin
    Tokens := FSessionSummary.Models[ChartIndexes[I]].Usage.TotalTokens;
    TopPos := CHART_TITLE_H + 8 + I * RowH;
    ModelText := ShortChartLabel(SessionModelCaption(FSessionSummary.Models[ChartIndexes[I]].ModelName));
    ValueText := CompactInt(Tokens);
    C.Brush.Style := bsClear;
    C.Font.Color := clBlack;
    C.TextOut(16, TopPos + 3, ModelText);

    BarW := Round(Tokens / MaxTokens * BarMaxW);
    if (Tokens > 0) and (BarW < 2) then
      BarW := 2;
    BarTop := TopPos + 5;
    C.Brush.Color := RGBToColor(54, 117, 202);
    C.Pen.Color := RGBToColor(54, 117, 202);
    C.Rectangle(BarLeft, BarTop, BarLeft + BarW, BarTop + 13);
    C.Brush.Style := bsClear;
    C.Font.Color := clBlack;
    C.TextOut(BarLeft + BarMaxW + 8, TopPos + 3, ValueText);
    C.Brush.Style := bsSolid;
  end;
end;

end.
