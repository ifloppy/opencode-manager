unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, Spin, oc_config, oc_omo_config, oc_paths, oc_profiles,
  oc_presets, oc_http;

type
  { TMainForm }

  TMainForm = class(TForm)
  private
    FConfig: TOpenCodeConfig;
    FOMO: TOMOConfig;
    FProfiles: TProfileManager;
    FModelListKeys: TStringList;
    NavPanel: TPanel;
    PageControl: TPageControl;
    Status: TStatusBar;

    ConfigPathEdit: TEdit;
    OMOPathEdit: TEdit;
    ValidationMemo: TMemo;
    RawMemo: TMemo;
    OMORawMemo: TMemo;

    ProviderList, ModelList, AgentList, McpList, PluginList, ProfileList: TListBox;
    ProviderNameEdit, ProviderBaseUrlEdit, ProviderApiKeyEdit: TEdit;
    ProviderIdEdit, ProviderNpmEdit: TComboBox;
    ModelIdEdit, ModelNameEdit: TEdit;
    AgentIdEdit, AgentDescriptionEdit, AgentModelEdit, AgentColorEdit: TEdit;
    AgentModeEdit: TComboBox;
    AgentPromptMemo: TMemo;
    AgentTempEdit: TFloatSpinEdit;
    AgentMaxStepsEdit: TSpinEdit;
    AgentDisabledCheck, AgentHiddenCheck: TCheckBox;
    AgentToolChecks: array[0..11] of TCheckBox;
    AgentDeleteButton: TButton;
    McpIdEdit, McpTargetEdit: TEdit;
    McpTypeEdit: TComboBox;
    McpEnabledCheck: TCheckBox;
    PluginNameEdit: TEdit;
    ProfileNameEdit: TEdit;

    OMOAgentList, OMOCategoryList: TListBox;
    OMOAgentIdEdit, OMOAgentModelEdit: TEdit;
    OMOAgentCategoryEdit, OMOAgentVariantEdit, OMOAgentThinkingEdit, OMOAgentReasoningEdit: TComboBox;
    OMOAgentPromptMemo: TMemo;
    OMOAgentTempEdit: TFloatSpinEdit;
    OMOAgentDisabledCheck: TCheckBox;
    OMOAgentDeleteButton: TButton;
    OMOCategoryIdEdit, OMOCategoryModelEdit, OMOCategoryDescEdit: TEdit;
    OMOCategoryVariantEdit, OMOCategoryThinkingEdit, OMOCategoryReasoningEdit: TComboBox;
    OMOCategoryPromptMemo: TMemo;
    OMOCategoryDisabledCheck: TCheckBox;

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
  Constraints.MinWidth := 820;
  Constraints.MinHeight := 560;
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
  AddLabel(Tab, 'OpenCode 配置', 16, 20);
  ConfigPathEdit := AddEdit(Tab, 130, 16, 760);
  ConfigPathEdit.Anchors := [akLeft, akTop, akRight];
  AddButton(Tab, '打开', 900, 15, 80, @OnOpenConfig);
  AddButton(Tab, '保存全部', 990, 15, 100, @OnSaveConfig);
  AddLabel(Tab, 'OMO 配置', 16, 58);
  OMOPathEdit := AddEdit(Tab, 130, 54, 760);
  OMOPathEdit.Anchors := [akLeft, akTop, akRight];
  AddButton(Tab, '重新加载', 900, 53, 100, @OnReload);
  AddButton(Tab, '校验', 1010, 53, 80, @OnValidate);
  ValidationMemo := TMemo.Create(Tab);
  ValidationMemo.Parent := Tab;
  ValidationMemo.SetBounds(16, 100, 1070, 560);
  ValidationMemo.Anchors := [akLeft, akTop, akRight, akBottom];
  ValidationMemo.Hint := '配置路径、校验结果和结构问题';
  ValidationMemo.ShowHint := True;
  ValidationMemo.ScrollBars := ssAutoBoth;
  ValidationMemo.ReadOnly := True;

  Tab := AddTab('Provider / Model');
  ProviderList := TListBox.Create(Tab); ProviderList.Parent := Tab; ProviderList.SetBounds(16, 16, 210, 260); ProviderList.Anchors := [akLeft, akTop, akBottom]; ProviderList.Hint := 'Provider 列表'; ProviderList.ShowHint := True; ProviderList.OnClick := @OnProviderSelect;
  AddLabel(Tab, 'Provider ID', 250, 20); ProviderIdEdit := AddCombo(Tab, 370, 16, 520, []); ProviderIdEdit.Anchors := [akLeft, akTop, akRight]; ProviderIdEdit.OnChange := @OnProviderPresetChange;
  for I := Low(PROVIDER_PRESETS) to High(PROVIDER_PRESETS) do
    ProviderIdEdit.Items.Add(PROVIDER_PRESETS[I].Id);
  AddLabel(Tab, '显示名', 250, 58); ProviderNameEdit := AddEdit(Tab, 370, 54, 520); ProviderNameEdit.Anchors := [akLeft, akTop, akRight];
  AddLabel(Tab, 'NPM SDK', 250, 96); ProviderNpmEdit := AddCombo(Tab, 370, 92, 520, NPM_SDK_PRESETS); ProviderNpmEdit.Anchors := [akLeft, akTop, akRight];
  AddLabel(Tab, 'Base URL', 250, 134); ProviderBaseUrlEdit := AddEdit(Tab, 370, 130, 520); ProviderBaseUrlEdit.Anchors := [akLeft, akTop, akRight];
  AddLabel(Tab, 'API Key', 250, 172); ProviderApiKeyEdit := AddEdit(Tab, 370, 168, 520); ProviderApiKeyEdit.Anchors := [akLeft, akTop, akRight];
  AddButton(Tab, '保存 Provider', 370, 210, 130, @OnSaveProvider);
  AddButton(Tab, '删除 Provider', 510, 210, 130, @OnDeleteProvider);
  ModelList := TListBox.Create(Tab); ModelList.Parent := Tab; ModelList.SetBounds(16, 292, 210, 328); ModelList.Anchors := [akLeft, akTop, akBottom]; ModelList.Hint := '模型列表：选择后状态栏显示完整名称和 key'; ModelList.ShowHint := True; ModelList.OnClick := @OnModelSelect;
  AddLabel(Tab, 'Model ID', 250, 292); ModelIdEdit := AddEdit(Tab, 370, 288, 520); ModelIdEdit.Anchors := [akLeft, akTop, akRight];
  AddLabel(Tab, '模型显示名', 250, 330); ModelNameEdit := AddEdit(Tab, 370, 326, 520); ModelNameEdit.Anchors := [akLeft, akTop, akRight];
  AddButton(Tab, '保存 Model', 370, 368, 130, @OnSaveModel);
  AddButton(Tab, '删除 Model', 510, 368, 130, @OnDeleteModel);
  AddButton(Tab, '测试连通性', 650, 368, 130, @OnTestModelConnectivity);

  Tab := AddTab('OpenCode Agent');
  AgentList := TListBox.Create(Tab); AgentList.Parent := Tab; AgentList.SetBounds(16, 16, 220, 610); AgentList.Anchors := [akLeft, akTop, akBottom]; AgentList.OnClick := @OnAgentSelect;
  AddLabel(Tab, 'Agent ID', 260, 20); AgentIdEdit := AddEdit(Tab, 380, 16, 520); AgentIdEdit.Anchors := [akLeft, akTop, akRight];
  AddLabel(Tab, '描述', 260, 58); AgentDescriptionEdit := AddEdit(Tab, 380, 54, 520); AgentDescriptionEdit.Anchors := [akLeft, akTop, akRight];
  AddLabel(Tab, '模式', 260, 96); AgentModeEdit := AddCombo(Tab, 380, 92, 160, AGENT_MODES); AgentModeEdit.Text := 'subagent';
  AddLabel(Tab, '模型', 260, 134); AgentModelEdit := AddEdit(Tab, 380, 130, 520); AgentModelEdit.Anchors := [akLeft, akTop, akRight];
  AddLabel(Tab, '温度', 260, 172); AgentTempEdit := TFloatSpinEdit.Create(Tab); AgentTempEdit.Parent := Tab; AgentTempEdit.SetBounds(380, 168, 100, 28); AgentTempEdit.Increment := 0.1; AgentTempEdit.DecimalPlaces := 2; AgentTempEdit.MinValue := 0; AgentTempEdit.MaxValue := 2;
  AgentDisabledCheck := TCheckBox.Create(Tab); AgentDisabledCheck.Parent := Tab; AgentDisabledCheck.Caption := '禁用'; AgentDisabledCheck.SetBounds(500, 170, 80, 24);
  AgentHiddenCheck := TCheckBox.Create(Tab); AgentHiddenCheck.Parent := Tab; AgentHiddenCheck.Caption := '隐藏'; AgentHiddenCheck.SetBounds(580, 170, 80, 24);
  AddLabel(Tab, '颜色', 610, 172); AgentColorEdit := AddEdit(Tab, 660, 168, 90);
  AddLabel(Tab, 'MaxSteps', 760, 172); AgentMaxStepsEdit := TSpinEdit.Create(Tab); AgentMaxStepsEdit.Parent := Tab; AgentMaxStepsEdit.SetBounds(840, 168, 80, 28); AgentMaxStepsEdit.MinValue := 0; AgentMaxStepsEdit.MaxValue := 1000;
  AddLabel(Tab, '工具', 260, 210);
  for I := Low(AGENT_TOOLS) to High(AGENT_TOOLS) do
  begin
    AgentToolChecks[I] := TCheckBox.Create(Tab);
    AgentToolChecks[I].Parent := Tab;
    AgentToolChecks[I].Caption := AGENT_TOOLS[I];
    AgentToolChecks[I].SetBounds(380 + (I mod 4) * 120, 210 + (I div 4) * 26, 115, 24);
  end;
  AddLabel(Tab, 'Prompt', 260, 300); AgentPromptMemo := TMemo.Create(Tab); AgentPromptMemo.Parent := Tab; AgentPromptMemo.SetBounds(380, 300, 620, 210); AgentPromptMemo.ScrollBars := ssAutoBoth; AgentPromptMemo.Anchors := [akLeft, akTop, akRight, akBottom];
  AddButton(Tab, '保存 Agent', 380, 530, 130, @OnSaveAgent);
  AgentDeleteButton := AddButton(Tab, '删除 Agent', 520, 530, 130, @OnDeleteAgent);

  Tab := AddTab('OMO Agents / Categories');
  OMOAgentList := TListBox.Create(Tab); OMOAgentList.Parent := Tab; OMOAgentList.SetBounds(16, 16, 210, 280); OMOAgentList.Anchors := [akLeft, akTop, akBottom]; OMOAgentList.Hint := 'OMO Agent 列表，内置项可编辑或禁用但不能删除'; OMOAgentList.ShowHint := True; OMOAgentList.OnClick := @OnOMOAgentSelect;
  AddLabel(Tab, 'Agent ID', 245, 20); OMOAgentIdEdit := AddEdit(Tab, 365, 16, 300);
  AddLabel(Tab, '模型', 245, 58); OMOAgentModelEdit := AddEdit(Tab, 365, 54, 300);
  AddLabel(Tab, 'Category', 245, 96); OMOAgentCategoryEdit := AddCombo(Tab, 365, 92, 300, OMO_CATEGORY_PRESETS);
  AddLabel(Tab, 'Variant', 245, 134); OMOAgentVariantEdit := AddCombo(Tab, 365, 130, 300, OMO_VARIANT_PRESETS);
  AddLabel(Tab, '温度', 245, 172); OMOAgentTempEdit := TFloatSpinEdit.Create(Tab); OMOAgentTempEdit.Parent := Tab; OMOAgentTempEdit.SetBounds(365, 168, 100, 28); OMOAgentTempEdit.Increment := 0.1; OMOAgentTempEdit.DecimalPlaces := 2; OMOAgentTempEdit.MaxValue := 2;
  OMOAgentDisabledCheck := TCheckBox.Create(Tab); OMOAgentDisabledCheck.Parent := Tab; OMOAgentDisabledCheck.Caption := '禁用'; OMOAgentDisabledCheck.SetBounds(490, 170, 80, 24);
  AddLabel(Tab, 'Thinking', 245, 210); OMOAgentThinkingEdit := AddCombo(Tab, 365, 206, 120, OMO_THINKING_OPTIONS);
  AddLabel(Tab, 'Reasoning', 500, 210); OMOAgentReasoningEdit := AddCombo(Tab, 590, 206, 120, OMO_REASONING_EFFORTS);
  OMOAgentPromptMemo := TMemo.Create(Tab); OMOAgentPromptMemo.Parent := Tab; OMOAgentPromptMemo.SetBounds(740, 16, 390, 250); OMOAgentPromptMemo.ScrollBars := ssAutoBoth; OMOAgentPromptMemo.Anchors := [akLeft, akTop, akRight, akBottom]; OMOAgentPromptMemo.Hint := 'OMO Agent prompt_append'; OMOAgentPromptMemo.ShowHint := True;
  AddButton(Tab, '保存 OMO Agent', 365, 245, 150, @OnSaveOMOAgent);
  OMOAgentDeleteButton := AddButton(Tab, '删除 OMO Agent', 525, 245, 150, @OnDeleteOMOAgent);
  OMOCategoryList := TListBox.Create(Tab); OMOCategoryList.Parent := Tab; OMOCategoryList.SetBounds(16, 330, 210, 280); OMOCategoryList.Anchors := [akLeft, akTop, akBottom]; OMOCategoryList.Hint := 'OMO Category 列表'; OMOCategoryList.ShowHint := True; OMOCategoryList.OnClick := @OnOMOCategorySelect;
  AddLabel(Tab, 'Category ID', 245, 334); OMOCategoryIdEdit := AddEdit(Tab, 365, 330, 300);
  AddLabel(Tab, '模型', 245, 372); OMOCategoryModelEdit := AddEdit(Tab, 365, 368, 300);
  AddLabel(Tab, '描述', 245, 410); OMOCategoryDescEdit := AddEdit(Tab, 365, 406, 300);
  AddLabel(Tab, 'Variant', 245, 448); OMOCategoryVariantEdit := AddCombo(Tab, 365, 444, 300, OMO_VARIANT_PRESETS);
  OMOCategoryDisabledCheck := TCheckBox.Create(Tab); OMOCategoryDisabledCheck.Parent := Tab; OMOCategoryDisabledCheck.Caption := '禁用'; OMOCategoryDisabledCheck.SetBounds(365, 482, 80, 24);
  AddLabel(Tab, 'Thinking', 245, 524); OMOCategoryThinkingEdit := AddCombo(Tab, 365, 520, 120, OMO_THINKING_OPTIONS);
  AddLabel(Tab, 'Reasoning', 500, 524); OMOCategoryReasoningEdit := AddCombo(Tab, 590, 520, 120, OMO_REASONING_EFFORTS);
  OMOCategoryPromptMemo := TMemo.Create(Tab); OMOCategoryPromptMemo.Parent := Tab; OMOCategoryPromptMemo.SetBounds(740, 330, 390, 250); OMOCategoryPromptMemo.ScrollBars := ssAutoBoth; OMOCategoryPromptMemo.Anchors := [akLeft, akBottom, akRight]; OMOCategoryPromptMemo.Hint := 'OMO Category prompt_append'; OMOCategoryPromptMemo.ShowHint := True;
  AddButton(Tab, '保存 Category', 365, 560, 150, @OnSaveOMOCategory);
  AddButton(Tab, '删除 Category', 525, 560, 150, @OnDeleteOMOCategory);

  Tab := AddTab('MCP / Plugin');
  McpList := TListBox.Create(Tab); McpList.Parent := Tab; McpList.SetBounds(16, 16, 220, 300); McpList.Anchors := [akLeft, akTop, akBottom]; McpList.Hint := 'MCP 列表'; McpList.ShowHint := True; McpList.OnClick := @OnMcpSelect;
  AddLabel(Tab, 'MCP ID', 260, 20); McpIdEdit := AddEdit(Tab, 380, 16, 260);
  AddLabel(Tab, '类型', 260, 58); McpTypeEdit := AddCombo(Tab, 380, 54, 160, MCP_TYPES); McpTypeEdit.Text := 'local';
  AddLabel(Tab, '命令或 URL', 260, 96); McpTargetEdit := AddEdit(Tab, 380, 92, 520);
  McpEnabledCheck := TCheckBox.Create(Tab); McpEnabledCheck.Parent := Tab; McpEnabledCheck.Caption := '启用'; McpEnabledCheck.Checked := True; McpEnabledCheck.SetBounds(380, 130, 80, 24);
  AddButton(Tab, '新增 MCP', 380, 170, 130, @OnNewMcp);
  AddButton(Tab, '保存 MCP', 520, 170, 130, @OnSaveMcp);
  AddButton(Tab, '删除 MCP', 660, 170, 130, @OnDeleteMcp);
  PluginList := TListBox.Create(Tab); PluginList.Parent := Tab; PluginList.SetBounds(16, 350, 220, 260); PluginList.Anchors := [akLeft, akTop, akBottom]; PluginList.Hint := 'Plugin 包列表'; PluginList.ShowHint := True; PluginList.OnClick := @OnPluginSelect;
  AddLabel(Tab, 'Plugin 包名', 260, 354); PluginNameEdit := AddEdit(Tab, 380, 350, 360);
  AddButton(Tab, '新增 Plugin', 380, 390, 130, @OnNewPlugin);
  AddButton(Tab, '保存 Plugin', 520, 390, 130, @OnSavePlugin);
  AddButton(Tab, '删除 Plugin', 660, 390, 130, @OnDeletePlugin);

  Tab := AddTab('Profile');
  ProfileList := TListBox.Create(Tab); ProfileList.Parent := Tab; ProfileList.SetBounds(16, 16, 260, 590); ProfileList.Anchors := [akLeft, akTop, akBottom];
  AddLabel(Tab, 'Profile 名称', 310, 20); ProfileNameEdit := AddEdit(Tab, 430, 16, 260);
  AddButton(Tab, '从当前配置创建', 430, 58, 160, @OnCreateProfile);
  AddButton(Tab, '删除 Profile', 600, 58, 130, @OnDeleteProfile);
  AddLabel(Tab, 'Profile 根目录: ' + FProfiles.RootDir, 310, 110);

  Tab := AddTab('原始 JSON');
  RawMemo := TMemo.Create(Tab); RawMemo.Parent := Tab; RawMemo.SetBounds(16, 16, 520, 590); RawMemo.ScrollBars := ssAutoBoth; RawMemo.Anchors := [akLeft, akTop, akBottom];
  OMORawMemo := TMemo.Create(Tab); OMORawMemo.Parent := Tab; OMORawMemo.SetBounds(552, 16, 520, 590); OMORawMemo.ScrollBars := ssAutoBoth; OMORawMemo.Anchors := [akLeft, akTop, akRight, akBottom];
  AddButton(Tab, '从原始 JSON 应用', 16, 620, 160, @OnApplyRaw);
  PageControl.ActivePageIndex := 0;
  UpdateNavigation;
  AdjustResponsiveLayout;
end;

procedure TMainForm.AdjustResponsiveLayout;
var
  W, H, ListGap, ListHeight, RawWidth, RightX, RightW, PromptH: Integer;
begin
  if Assigned(ProviderList) then
  begin
    H := ProviderList.Parent.ClientHeight;
    if H > 460 then
    begin
      ListGap := 16;
      ListHeight := (H - 48) div 2;
      ProviderList.SetBounds(16, 16, 210, ListHeight);
      ModelList.SetBounds(16, 16 + ListHeight + ListGap, 210, H - (32 + ListHeight + ListGap));
    end;
  end;

  if Assigned(RawMemo) then
  begin
    W := RawMemo.Parent.ClientWidth;
    H := RawMemo.Parent.ClientHeight;
    RawWidth := (W - 64) div 2;
    if RawWidth < 240 then
      RawWidth := 240;
    RawMemo.SetBounds(16, 16, RawWidth, H - 80);
    OMORawMemo.SetBounds(32 + RawWidth, 16, W - RawWidth - 48, H - 80);
  end;

  if Assigned(OMOAgentPromptMemo) then
  begin
    W := OMOAgentPromptMemo.Parent.ClientWidth;
    H := OMOAgentPromptMemo.Parent.ClientHeight;
    RightX := 740;
    if W - RightX < 280 then
      RightX := W - 300;
    if RightX < 680 then
      RightX := 680;
    RightW := W - RightX - 16;
    if RightW < 260 then
      RightW := 260;
    PromptH := (H - 62) div 2;
    if PromptH < 150 then
      PromptH := 150;
    OMOAgentPromptMemo.SetBounds(RightX, 16, RightW, PromptH);
    OMOCategoryPromptMemo.SetBounds(RightX, 32 + PromptH, RightW, H - PromptH - 48);
  end;

  if Assigned(McpList) then
  begin
    H := McpList.Parent.ClientHeight;
    if H > 500 then
    begin
      McpList.SetBounds(16, 16, 220, (H - 64) div 2);
      PluginList.SetBounds(16, 48 + McpList.Height, 220, H - McpList.Height - 64);
    end;
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
  Status.SimpleText := '已加载: ' + ConfigPathEdit.Text;
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

end.
