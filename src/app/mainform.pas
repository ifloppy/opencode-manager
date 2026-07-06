unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, Spin, oc_config, oc_omo_config, oc_paths, oc_profiles,
  oc_json;

type
  { TMainForm }

  TMainForm = class(TForm)
  private
    FConfig: TOpenCodeConfig;
    FOMO: TOMOConfig;
    FProfiles: TProfileManager;
    HeaderPanel: TPanel;
    PageControl: TPageControl;
    Status: TStatusBar;
    FDesignPPI: Integer;

    ConfigPathEdit: TEdit;
    OMOPathEdit: TEdit;
    ValidationMemo: TMemo;
    RawMemo: TMemo;
    OMORawMemo: TMemo;

    ProviderList, ModelList, AgentList, McpList, PluginList, ProfileList: TListBox;
    ProviderIdEdit, ProviderNameEdit, ProviderNpmEdit, ProviderBaseUrlEdit, ProviderApiKeyEdit: TEdit;
    ModelIdEdit, ModelNameEdit: TEdit;
    AgentIdEdit, AgentDescriptionEdit, AgentModeEdit, AgentModelEdit: TEdit;
    AgentPromptMemo: TMemo;
    AgentTempEdit: TFloatSpinEdit;
    AgentDisabledCheck: TCheckBox;
    McpIdEdit, McpTypeEdit, McpTargetEdit: TEdit;
    McpEnabledCheck: TCheckBox;
    PluginNameEdit: TEdit;
    ProfileNameEdit: TEdit;

    OMOAgentList, OMOCategoryList: TListBox;
    OMOAgentIdEdit, OMOAgentModelEdit, OMOAgentCategoryEdit, OMOAgentVariantEdit: TEdit;
    OMOAgentPromptMemo: TMemo;
    OMOAgentTempEdit: TFloatSpinEdit;
    OMOAgentDisabledCheck: TCheckBox;
    OMOCategoryIdEdit, OMOCategoryModelEdit, OMOCategoryDescEdit, OMOCategoryVariantEdit: TEdit;
    OMOCategoryPromptMemo: TMemo;
    OMOCategoryDisabledCheck: TCheckBox;

    procedure BuildUi;
    procedure ConfigureModernWindow;
    procedure ApplyModernStyle(AControl: TControl);
    procedure SetScaledBounds(AControl: TControl; LeftPos, TopPos, WidthValue, HeightValue: Integer);
    function ScaleValue(Value: Integer): Integer;
    function AddTab(const ACaption: string): TTabSheet;
    function AddButton(AParent: TWinControl; const ACaption: string; LeftPos, TopPos, WidthValue: Integer; Handler: TNotifyEvent): TButton;
    function AddLabel(AParent: TWinControl; const ACaption: string; LeftPos, TopPos: Integer): TLabel;
    function AddEdit(AParent: TWinControl; LeftPos, TopPos, WidthValue: Integer): TEdit;
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
    function ObjectInSection(Root: TJSONObject; const Section, Id: string): TJSONObject;

    procedure OnOpenConfig(Sender: TObject);
    procedure OnSaveConfig(Sender: TObject);
    procedure OnReload(Sender: TObject);
    procedure OnValidate(Sender: TObject);
    procedure OnApplyRaw(Sender: TObject);
    procedure OnProviderSelect(Sender: TObject);
    procedure OnModelSelect(Sender: TObject);
    procedure OnSaveProvider(Sender: TObject);
    procedure OnDeleteProvider(Sender: TObject);
    procedure OnSaveModel(Sender: TObject);
    procedure OnDeleteModel(Sender: TObject);
    procedure OnAgentSelect(Sender: TObject);
    procedure OnSaveAgent(Sender: TObject);
    procedure OnDeleteAgent(Sender: TObject);
    procedure OnMcpSelect(Sender: TObject);
    procedure OnSaveMcp(Sender: TObject);
    procedure OnDeleteMcp(Sender: TObject);
    procedure OnPluginSelect(Sender: TObject);
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
  FDesignPPI := 96;
  Width := ScaleValue(1180);
  Height := ScaleValue(780);
  Position := poScreenCenter;
  ConfigureModernWindow;
  FConfig := TOpenCodeConfig.Create;
  FOMO := TOMOConfig.Create;
  FProfiles := TProfileManager.Create;
  BuildUi;
  LoadDefaultConfigs;
end;

function TMainForm.ScaleValue(Value: Integer): Integer;
begin
  if Screen.PixelsPerInch > 0 then
    Result := (Value * Screen.PixelsPerInch + (FDesignPPI div 2)) div FDesignPPI
  else
    Result := Value;
end;

procedure TMainForm.SetScaledBounds(AControl: TControl; LeftPos, TopPos, WidthValue, HeightValue: Integer);
begin
  AControl.SetBounds(ScaleValue(LeftPos), ScaleValue(TopPos), ScaleValue(WidthValue), ScaleValue(HeightValue));
end;

procedure TMainForm.ConfigureModernWindow;
begin
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  Color := $00F7F7F7;
  Constraints.MinWidth := ScaleValue(1024);
  Constraints.MinHeight := ScaleValue(680);
  AutoScroll := False;
end;

procedure TMainForm.ApplyModernStyle(AControl: TControl);
var
  I: Integer;
  Win: TWinControl;
begin
  AControl.Font.Name := 'Segoe UI';
  if AControl is TPanel then
  begin
    TPanel(AControl).BevelOuter := bvNone;
    if AControl = HeaderPanel then
      TPanel(AControl).Color := clWhite
    else
      TPanel(AControl).Color := $00F7F7F7;
  end
  else if AControl is TButton then
  begin
    TButton(AControl).Height := ScaleValue(32);
    TButton(AControl).Constraints.MinHeight := ScaleValue(32);
  end
  else if AControl is TEdit then
    TEdit(AControl).BorderStyle := bsSingle
  else if AControl is TMemo then
  begin
    TMemo(AControl).BorderStyle := bsSingle;
    TMemo(AControl).Color := clWhite;
  end
  else if AControl is TListBox then
  begin
    TListBox(AControl).BorderStyle := bsSingle;
    TListBox(AControl).Color := clWhite;
  end;

  if AControl is TWinControl then
  begin
    Win := TWinControl(AControl);
    for I := 0 to Win.ControlCount - 1 do
      ApplyModernStyle(Win.Controls[I]);
  end;
end;

destructor TMainForm.Destroy;
begin
  FProfiles.Free;
  FOMO.Free;
  FConfig.Free;
  inherited Destroy;
end;

function TMainForm.AddTab(const ACaption: string): TTabSheet;
begin
  Result := TTabSheet.Create(PageControl);
  Result.PageControl := PageControl;
  Result.Caption := ACaption;
  Result.Color := $00F7F7F7;
end;

function TMainForm.AddButton(AParent: TWinControl; const ACaption: string; LeftPos, TopPos, WidthValue: Integer; Handler: TNotifyEvent): TButton;
begin
  Result := TButton.Create(AParent);
  Result.Parent := AParent;
  Result.Caption := ACaption;
  SetScaledBounds(Result, LeftPos, TopPos, WidthValue, 32);
  Result.OnClick := Handler;
end;

function TMainForm.AddLabel(AParent: TWinControl; const ACaption: string; LeftPos, TopPos: Integer): TLabel;
begin
  Result := TLabel.Create(AParent);
  Result.Parent := AParent;
  Result.Caption := ACaption;
  SetScaledBounds(Result, LeftPos, TopPos, 120, 24);
  Result.Font.Color := $00444444;
end;

function TMainForm.AddEdit(AParent: TWinControl; LeftPos, TopPos, WidthValue: Integer): TEdit;
begin
  Result := TEdit.Create(AParent);
  Result.Parent := AParent;
  SetScaledBounds(Result, LeftPos, TopPos, WidthValue, 30);
end;

procedure TMainForm.BuildUi;
var
  Tab: TTabSheet;
  HeaderTitle, HeaderSubtitle: TLabel;
begin
  HeaderPanel := TPanel.Create(Self);
  HeaderPanel.Parent := Self;
  HeaderPanel.Align := alTop;
  HeaderPanel.Height := ScaleValue(58);
  HeaderPanel.Color := $00FFFFFF;
  HeaderPanel.BevelOuter := bvNone;
  HeaderTitle := TLabel.Create(HeaderPanel);
  HeaderTitle.Parent := HeaderPanel;
  HeaderTitle.Caption := 'OpenCode 配置管理器';
  HeaderTitle.Font.Name := 'Segoe UI';
  HeaderTitle.Font.Size := 14;
  HeaderTitle.Font.Style := [fsBold];
  HeaderTitle.Font.Color := $00202020;
  SetScaledBounds(HeaderTitle, 16, 8, 280, 28);

  HeaderSubtitle := TLabel.Create(HeaderPanel);
  HeaderSubtitle.Parent := HeaderPanel;
  HeaderSubtitle.Caption := '管理 OpenCode、Oh My OpenAgent、Provider、Agent、Plugin 与 Profile';
  HeaderSubtitle.Font.Name := 'Segoe UI';
  HeaderSubtitle.Font.Size := 9;
  HeaderSubtitle.Font.Color := $00606060;
  SetScaledBounds(HeaderSubtitle, 16, 34, 620, 20);

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
  SetScaledBounds(ValidationMemo, 16, 100, 1070, 560);
  ValidationMemo.Anchors := [akLeft, akTop, akRight, akBottom];
  ValidationMemo.ScrollBars := ssAutoBoth;
  ValidationMemo.ReadOnly := True;

  Tab := AddTab('Provider / Model');
  ProviderList := TListBox.Create(Tab); ProviderList.Parent := Tab; SetScaledBounds(ProviderList, 16, 16, 210, 290); ProviderList.OnClick := @OnProviderSelect;
  AddLabel(Tab, 'Provider ID', 250, 20); ProviderIdEdit := AddEdit(Tab, 370, 16, 260);
  AddLabel(Tab, '显示名', 250, 58); ProviderNameEdit := AddEdit(Tab, 370, 54, 260);
  AddLabel(Tab, 'NPM SDK', 250, 96); ProviderNpmEdit := AddEdit(Tab, 370, 92, 260);
  AddLabel(Tab, 'Base URL', 250, 134); ProviderBaseUrlEdit := AddEdit(Tab, 370, 130, 420);
  AddLabel(Tab, 'API Key/env', 250, 172); ProviderApiKeyEdit := AddEdit(Tab, 370, 168, 420);
  AddButton(Tab, '保存 Provider', 370, 210, 130, @OnSaveProvider);
  AddButton(Tab, '删除 Provider', 510, 210, 130, @OnDeleteProvider);
  ModelList := TListBox.Create(Tab); ModelList.Parent := Tab; SetScaledBounds(ModelList, 16, 330, 210, 290); ModelList.OnClick := @OnModelSelect;
  AddLabel(Tab, 'Model ID', 250, 334); ModelIdEdit := AddEdit(Tab, 370, 330, 360);
  AddLabel(Tab, '模型显示名', 250, 372); ModelNameEdit := AddEdit(Tab, 370, 368, 360);
  AddButton(Tab, '保存 Model', 370, 410, 130, @OnSaveModel);
  AddButton(Tab, '删除 Model', 510, 410, 130, @OnDeleteModel);

  Tab := AddTab('OpenCode Agent');
  AgentList := TListBox.Create(Tab); AgentList.Parent := Tab; SetScaledBounds(AgentList, 16, 16, 220, 610); AgentList.Anchors := [akLeft, akTop, akBottom]; AgentList.OnClick := @OnAgentSelect;
  AddLabel(Tab, 'Agent ID', 260, 20); AgentIdEdit := AddEdit(Tab, 380, 16, 260);
  AddLabel(Tab, '描述', 260, 58); AgentDescriptionEdit := AddEdit(Tab, 380, 54, 520);
  AddLabel(Tab, '模式', 260, 96); AgentModeEdit := AddEdit(Tab, 380, 92, 160); AgentModeEdit.Text := 'subagent';
  AddLabel(Tab, '模型', 260, 134); AgentModelEdit := AddEdit(Tab, 380, 130, 360);
  AddLabel(Tab, '温度', 260, 172); AgentTempEdit := TFloatSpinEdit.Create(Tab); AgentTempEdit.Parent := Tab; SetScaledBounds(AgentTempEdit, 380, 168, 100, 30); AgentTempEdit.Increment := 0.1; AgentTempEdit.DecimalPlaces := 2; AgentTempEdit.MinValue := 0; AgentTempEdit.MaxValue := 2;
  AgentDisabledCheck := TCheckBox.Create(Tab); AgentDisabledCheck.Parent := Tab; AgentDisabledCheck.Caption := '禁用'; SetScaledBounds(AgentDisabledCheck, 500, 170, 80, 24);
  AddLabel(Tab, 'Prompt', 260, 210); AgentPromptMemo := TMemo.Create(Tab); AgentPromptMemo.Parent := Tab; SetScaledBounds(AgentPromptMemo, 380, 210, 620, 300); AgentPromptMemo.ScrollBars := ssAutoBoth; AgentPromptMemo.Anchors := [akLeft, akTop, akRight, akBottom];
  AddButton(Tab, '保存 Agent', 380, 530, 130, @OnSaveAgent);
  AddButton(Tab, '删除 Agent', 520, 530, 130, @OnDeleteAgent);

  Tab := AddTab('OMO Agents / Categories');
  OMOAgentList := TListBox.Create(Tab); OMOAgentList.Parent := Tab; SetScaledBounds(OMOAgentList, 16, 16, 210, 280); OMOAgentList.OnClick := @OnOMOAgentSelect;
  AddLabel(Tab, 'Agent ID', 245, 20); OMOAgentIdEdit := AddEdit(Tab, 365, 16, 220);
  AddLabel(Tab, '模型', 245, 58); OMOAgentModelEdit := AddEdit(Tab, 365, 54, 300);
  AddLabel(Tab, 'Category', 245, 96); OMOAgentCategoryEdit := AddEdit(Tab, 365, 92, 220);
  AddLabel(Tab, 'Variant', 245, 134); OMOAgentVariantEdit := AddEdit(Tab, 365, 130, 120);
  AddLabel(Tab, '温度', 245, 172); OMOAgentTempEdit := TFloatSpinEdit.Create(Tab); OMOAgentTempEdit.Parent := Tab; SetScaledBounds(OMOAgentTempEdit, 365, 168, 100, 30); OMOAgentTempEdit.Increment := 0.1; OMOAgentTempEdit.DecimalPlaces := 2; OMOAgentTempEdit.MaxValue := 2;
  OMOAgentDisabledCheck := TCheckBox.Create(Tab); OMOAgentDisabledCheck.Parent := Tab; OMOAgentDisabledCheck.Caption := '禁用'; SetScaledBounds(OMOAgentDisabledCheck, 490, 170, 80, 24);
  OMOAgentPromptMemo := TMemo.Create(Tab); OMOAgentPromptMemo.Parent := Tab; SetScaledBounds(OMOAgentPromptMemo, 680, 16, 390, 180); OMOAgentPromptMemo.ScrollBars := ssAutoBoth; OMOAgentPromptMemo.Anchors := [akLeft, akTop, akRight];
  AddButton(Tab, '保存 OMO Agent', 365, 215, 150, @OnSaveOMOAgent);
  AddButton(Tab, '删除 OMO Agent', 525, 215, 150, @OnDeleteOMOAgent);
  OMOCategoryList := TListBox.Create(Tab); OMOCategoryList.Parent := Tab; SetScaledBounds(OMOCategoryList, 16, 330, 210, 280); OMOCategoryList.OnClick := @OnOMOCategorySelect;
  AddLabel(Tab, 'Category ID', 245, 334); OMOCategoryIdEdit := AddEdit(Tab, 365, 330, 220);
  AddLabel(Tab, '模型', 245, 372); OMOCategoryModelEdit := AddEdit(Tab, 365, 368, 300);
  AddLabel(Tab, '描述', 245, 410); OMOCategoryDescEdit := AddEdit(Tab, 365, 406, 300);
  AddLabel(Tab, 'Variant', 245, 448); OMOCategoryVariantEdit := AddEdit(Tab, 365, 444, 120);
  OMOCategoryDisabledCheck := TCheckBox.Create(Tab); OMOCategoryDisabledCheck.Parent := Tab; OMOCategoryDisabledCheck.Caption := '禁用'; SetScaledBounds(OMOCategoryDisabledCheck, 500, 446, 80, 24);
  OMOCategoryPromptMemo := TMemo.Create(Tab); OMOCategoryPromptMemo.Parent := Tab; SetScaledBounds(OMOCategoryPromptMemo, 680, 330, 390, 180); OMOCategoryPromptMemo.ScrollBars := ssAutoBoth; OMOCategoryPromptMemo.Anchors := [akLeft, akTop, akRight];
  AddButton(Tab, '保存 Category', 365, 530, 150, @OnSaveOMOCategory);
  AddButton(Tab, '删除 Category', 525, 530, 150, @OnDeleteOMOCategory);

  Tab := AddTab('MCP / Plugin');
  McpList := TListBox.Create(Tab); McpList.Parent := Tab; SetScaledBounds(McpList, 16, 16, 220, 300); McpList.OnClick := @OnMcpSelect;
  AddLabel(Tab, 'MCP ID', 260, 20); McpIdEdit := AddEdit(Tab, 380, 16, 260);
  AddLabel(Tab, '类型 local/remote', 260, 58); McpTypeEdit := AddEdit(Tab, 380, 54, 160); McpTypeEdit.Text := 'local';
  AddLabel(Tab, '命令或 URL', 260, 96); McpTargetEdit := AddEdit(Tab, 380, 92, 520);
  McpEnabledCheck := TCheckBox.Create(Tab); McpEnabledCheck.Parent := Tab; McpEnabledCheck.Caption := '启用'; McpEnabledCheck.Checked := True; SetScaledBounds(McpEnabledCheck, 380, 130, 80, 24);
  AddButton(Tab, '保存 MCP', 380, 170, 130, @OnSaveMcp);
  AddButton(Tab, '删除 MCP', 520, 170, 130, @OnDeleteMcp);
  PluginList := TListBox.Create(Tab); PluginList.Parent := Tab; SetScaledBounds(PluginList, 16, 350, 220, 260); PluginList.OnClick := @OnPluginSelect;
  AddLabel(Tab, 'Plugin 包名', 260, 354); PluginNameEdit := AddEdit(Tab, 380, 350, 360);
  AddButton(Tab, '保存 Plugin', 380, 390, 130, @OnSavePlugin);
  AddButton(Tab, '删除 Plugin', 520, 390, 130, @OnDeletePlugin);

  Tab := AddTab('Profile');
  ProfileList := TListBox.Create(Tab); ProfileList.Parent := Tab; SetScaledBounds(ProfileList, 16, 16, 260, 590); ProfileList.Anchors := [akLeft, akTop, akBottom];
  AddLabel(Tab, 'Profile 名称', 310, 20); ProfileNameEdit := AddEdit(Tab, 430, 16, 260);
  AddButton(Tab, '从当前配置创建', 430, 58, 160, @OnCreateProfile);
  AddButton(Tab, '删除 Profile', 600, 58, 130, @OnDeleteProfile);
  AddLabel(Tab, 'Profile 根目录: ' + FProfiles.RootDir, 310, 110);

  Tab := AddTab('原始 JSON');
  RawMemo := TMemo.Create(Tab); RawMemo.Parent := Tab; SetScaledBounds(RawMemo, 16, 16, 520, 590); RawMemo.ScrollBars := ssAutoBoth; RawMemo.Anchors := [akLeft, akTop, akBottom];
  OMORawMemo := TMemo.Create(Tab); OMORawMemo.Parent := Tab; SetScaledBounds(OMORawMemo, 552, 16, 520, 590); OMORawMemo.ScrollBars := ssAutoBoth; OMORawMemo.Anchors := [akLeft, akTop, akRight, akBottom];
  AddButton(Tab, '从原始 JSON 应用', 16, 620, 160, @OnApplyRaw);
  ApplyModernStyle(Self);
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
end;

procedure TMainForm.RefreshAgentList;
var
  L: TStringList;
begin
  L := FConfig.AgentIds;
  try
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
begin
  L := FOMO.AgentIds;
  try
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
  Provider, Options: TJSONObject;
  L: TStringList;
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
    ModelList.Items.Assign(L);
  finally
    L.Free;
  end;
end;

procedure TMainForm.OnModelSelect(Sender: TObject);
var
  Provider, Models, ModelObj: TJSONObject;
begin
  ModelIdEdit.Text := SelectedText(ModelList);
  ModelNameEdit.Text := '';
  Provider := ObjectInSection(FConfig.Data, 'provider', ProviderIdEdit.Text);
  if Assigned(Provider) and (Provider.Find('models') is TJSONObject) then
  begin
    Models := TJSONObject(Provider.Find('models'));
    if Models.Find(ModelIdEdit.Text) is TJSONObject then
    begin
      ModelObj := TJSONObject(Models.Find(ModelIdEdit.Text));
      ModelNameEdit.Text := ModelObj.Get('name', '');
    end;
  end;
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
  FConfig.DeleteModel(ProviderIdEdit.Text, ModelIdEdit.Text);
  RefreshAll;
end;

procedure TMainForm.OnAgentSelect(Sender: TObject);
var
  Agent: TJSONObject;
begin
  AgentIdEdit.Text := SelectedText(AgentList);
  Agent := ObjectInSection(FConfig.Data, 'agent', AgentIdEdit.Text);
  if Assigned(Agent) then
  begin
    AgentDescriptionEdit.Text := Agent.Get('description', '');
    AgentModeEdit.Text := Agent.Get('mode', 'all');
    AgentModelEdit.Text := Agent.Get('model', '');
    AgentPromptMemo.Text := Agent.Get('prompt', '');
    AgentTempEdit.Value := Agent.Get('temperature', 0.0);
    AgentDisabledCheck.Checked := Agent.Get('disable', False);
  end;
end;

procedure TMainForm.OnSaveAgent(Sender: TObject);
begin
  FConfig.UpsertAgent(AgentIdEdit.Text, AgentDescriptionEdit.Text, AgentModeEdit.Text, AgentModelEdit.Text, AgentPromptMemo.Text, AgentTempEdit.Value, AgentDisabledCheck.Checked);
  RefreshAll;
end;

procedure TMainForm.OnDeleteAgent(Sender: TObject);
begin
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
    if McpTypeEdit.Text = 'remote' then
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

procedure TMainForm.OnSaveMcp(Sender: TObject);
begin
  if LowerCase(McpTypeEdit.Text) = 'remote' then
    FConfig.UpsertMcpRemote(McpIdEdit.Text, McpTargetEdit.Text, McpEnabledCheck.Checked)
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
begin
  OMOAgentIdEdit.Text := SelectedText(OMOAgentList);
  Agent := ObjectInSection(FOMO.Data, 'agents', OMOAgentIdEdit.Text);
  if Assigned(Agent) then
  begin
    OMOAgentModelEdit.Text := Agent.Get('model', '');
    OMOAgentCategoryEdit.Text := Agent.Get('category', '');
    OMOAgentVariantEdit.Text := Agent.Get('variant', '');
    OMOAgentPromptMemo.Text := Agent.Get('prompt_append', '');
    OMOAgentTempEdit.Value := Agent.Get('temperature', 0.0);
    OMOAgentDisabledCheck.Checked := Agent.Get('disable', False);
  end;
end;

procedure TMainForm.OnSaveOMOAgent(Sender: TObject);
begin
  FOMO.UpsertAgent(OMOAgentIdEdit.Text, OMOAgentModelEdit.Text, OMOAgentCategoryEdit.Text, OMOAgentVariantEdit.Text, OMOAgentPromptMemo.Text, OMOAgentTempEdit.Value, OMOAgentDisabledCheck.Checked);
  RefreshAll;
end;

procedure TMainForm.OnDeleteOMOAgent(Sender: TObject);
begin
  FOMO.DeleteAgent(OMOAgentIdEdit.Text);
  RefreshAll;
end;

procedure TMainForm.OnOMOCategorySelect(Sender: TObject);
var
  Category: TJSONObject;
begin
  OMOCategoryIdEdit.Text := SelectedText(OMOCategoryList);
  Category := ObjectInSection(FOMO.Data, 'categories', OMOCategoryIdEdit.Text);
  if Assigned(Category) then
  begin
    OMOCategoryModelEdit.Text := Category.Get('model', '');
    OMOCategoryDescEdit.Text := Category.Get('description', '');
    OMOCategoryVariantEdit.Text := Category.Get('variant', '');
    OMOCategoryPromptMemo.Text := Category.Get('prompt_append', '');
    OMOCategoryDisabledCheck.Checked := Category.Get('disable', False);
  end;
end;

procedure TMainForm.OnSaveOMOCategory(Sender: TObject);
begin
  FOMO.UpsertCategory(OMOCategoryIdEdit.Text, OMOCategoryModelEdit.Text, OMOCategoryDescEdit.Text, OMOCategoryVariantEdit.Text, OMOCategoryPromptMemo.Text, OMOCategoryDisabledCheck.Checked);
  RefreshAll;
end;

procedure TMainForm.OnDeleteOMOCategory(Sender: TObject);
begin
  FOMO.DeleteCategory(OMOCategoryIdEdit.Text);
  RefreshAll;
end;

end.
