unit ufrmMain;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ExtCtrls, Data.Bind.Components, Data.Bind.EngExt, Vcl.Bind.DBEngExt, DosCommand, Vcl.CheckLst, Vcl.ComCtrls,
  Vcl.Menus, Vcl.Mask, Vcl.BaseImageCollection, Vcl.ImageCollection, Vcl.Imaging.pngimage,
  System.Generics.Collections, System.Generics.Defaults, uGetItTypes;

type
  TfrmMain = class(TForm)
    pnlTop: TPanel;
    btnRefreshGetItCmd: TBitBtn;
    aclAutoGetit: TActionList;
    actRefresh: TAction;
    cmbRADVersions: TComboBox;
    Label1: TLabel;
    DosCommand: TDosCommand;
    lbPackages: TCheckListBox;
    actInstallChecked: TAction;
    rgrpSortBy: TRadioGroup;
    chkInstalledOnly: TCheckBox;
    edtNameFilter: TLabeledEdit;
    StatusBar: TStatusBar;
    mnuCheckListPopup: TPopupMenu;
    actSaveCheckedList: TAction;
    actCheckAll: TAction;
    CheckAll1: TMenuItem;
    Savedcheckeditems1: TMenuItem;
    actUncheckAll: TAction;
    UncheckAll1: TMenuItem;
    MenuSeparator1: TMenuItem;
    InstallChecked1: TMenuItem;
    MenuSeparator2: TMenuItem;
    chkAcceptEULAs: TCheckBox;
    btnInstallSelected: TBitBtn;
    actUninstallChecked: TAction;
    UninstallChecked1: TMenuItem;
    FileOpenDialogSavedChecks: TFileOpenDialog;
    FileSaveDialogSavedChecks: TFileSaveDialog;
    actLoadCheckedList: TAction;
    dlgClearChecksFirst: TTaskDialog;
    actLoadCheckedList1: TMenuItem;
    actInstallOne: TAction;
    Installhighlightedpackage1: TMenuItem;
    actUninstallOne: TAction;
    Uninstallhighlightedpackage1: TMenuItem;
    Label2: TLabel;
    mmoDescription: TMemo;
    BindingsList1: TBindingsList;
    Splitter1: TSplitter;
    panelGetItCmd: TPanel;
    pnlInstall: TPanel;
    imlAG: TImageCollection;
    btnOutputLog: TBitBtn;
    lblGetItMode: TLabel;
    binstallselected: TButton;
    FLblCategoryFilter: TLabel;
    FCmbCategoryFilter: TComboBox;
    FLblVersionState: TLabel;
    panelRest: TPanel;
    btnRefreshRest: TBitBtn;
    chkNotInstalledOnly: TCheckBox;
    lFilterRestList: TLabeledEdit;
    FChkDelphiOnly: TCheckBox;
    FChkLatestOnly: TCheckBox;
    cbInstalledRest: TCheckBox;
    btnToggleGetItMode: TBitBtn;
    lAdvise: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DosCommandNewLine(ASender: TObject; const ANewLine: string; AOutputType: TOutputType);
    procedure DosCommandTerminated(Sender: TObject);
    procedure btnOutputLogClick(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actInstallCheckedExecute(Sender: TObject);
    procedure actCheckAllExecute(Sender: TObject);
    procedure actUncheckAllExecute(Sender: TObject);
    procedure actUninstallCheckedExecute(Sender: TObject);
    procedure actSaveCheckedListExecute(Sender: TObject);
    procedure actLoadCheckedListExecute(Sender: TObject);
    procedure actInstallOneExecute(Sender: TObject);
    procedure actUninstallOneExecute(Sender: TObject);
    procedure lbPackagesClick(Sender: TObject);
    procedure rgrpSortByClick(Sender: TObject);
    procedure cmbRADVersionsChange(Sender: TObject);
    procedure btnRefreshRestClick(Sender: TObject);
    procedure chkInstalledOnlyClick(Sender: TObject);
    procedure cbInstalledRestClick(Sender: TObject);
    procedure chkNotInstalledOnlyClick(Sender: TObject);
    procedure binstallselectedClick(Sender: TObject);
    procedure CategoryFilterChange(Sender: TObject);
    procedure edtNameFilterChange(Sender: TObject);
    procedure ScopeFilterChange(Sender: TObject);
    procedure btnToggleGetItModeClick(Sender: TObject);
  private
    const
      BDS_USER_ROOT = '\Software\Embarcadero\BDS\';
      BDS_MACHINE_WOW6432_ROOT = '\SOFTWARE\WOW6432Node\Embarcadero\BDS\';
      TEXT_FILTER_MIN_CHARS = 3;
    type
      TGetItArgsFunction = reference to function (const GetItName: string): string;
    var
      FPastFirstItem: Boolean;
      FFinished: Boolean;
      FPackageNewLine: string;
      FInstallAborted: Boolean;
      FOutputLog: TStringList;
      FOutputErrorDetected: Boolean;
      FOutputWarningDetected: Boolean;
      FListSource: TListSource;
      FTextFilterActive: Boolean;
      FPackageInfoById: TObjectDictionary<string, TGetItPackageInfo>;
      FMenuDownloadViaGetItCmd: TMenuItem;
      FMenuDownloadDirectRest: TMenuItem;
      FMenuSortLocal: TMenuItem;
      FMenuSortId: TMenuItem;
      FMenuSortVersion: TMenuItem;
      FMenuSortName: TMenuItem;
      FMenuSortVendor: TMenuItem;
      FMenuSortCategory: TMenuItem;
      FMenuSortDate: TMenuItem;
      FLocalSortIndex: Integer;
      FColWidthId: Integer;
      FColWidthVersion: Integer;
      FColWidthName: Integer;
      FColWidthVendor: Integer;
      FColWidthType: Integer;
      FColWidthSub: Integer;
      FColWidthSize: Integer;
      FColWidthStatus: Integer;
    procedure SetExecLine(const Value: string);
    procedure SetDownloadTime(const Value: Integer);
    procedure SetPackageCount(const Value: Integer);
    procedure AppendOutputLog(const LogMsg: string);
    procedure UpdateOutputLogButtonState;
    procedure SetOutputErrorDetected(const Value: Boolean);
    procedure SetOutputWarningDetected(const Value: Boolean);
    procedure ResetListParserState;
    procedure FlushCurrentPackageLine;
    procedure ParseGetItOutputLine(const ANewLine: string; AOutputType: TOutputType;
                                   const AddToLog: Boolean = True);
    function ReadCatalogRepositoryStringValue(const ValueName: string): string;
    function GetDefaultServiceUrlForSelectedVersion: string;
    function GetServiceUrlForSelectedVersion: string;
    function GetCatalogVersionForSelectedVersion: string;
    function GetProductIdForSelectedVersion: string;
    function GetProductSkuForSelectedVersion: string;
    function GetInstalledPackageIdsFromRegistry: TDictionary<string, Byte>;
    function GetInstalledPackageVersionsFromRegistry: TDictionary<string, string>;
    procedure ApplyMutuallyExclusiveFilter(const ChangedFilter: TCheckBox);
    procedure UpdateVersionStatusAndLabel;
    procedure UpdateInstallSelectedButtonState;
    procedure UpdatePackageActionsState;
    procedure ResetCategoryFilter;
    procedure UpdateCategoryFilterItems;
    function VisiblePackageCount: Integer;
    function BuildListHeaderRow: string;
    function PackageInfoFromItemIndex(const Index: Integer; out Pkg: TGetItPackageInfo): Boolean;
    function GetPackageIdFromItemIndex(const Index: Integer): string;
    function StatusTextForPackage(const Pkg: TGetItPackageInfo): string;
    function CategoryTextForPackage(const Pkg: TGetItPackageInfo): string;
    function PackageMatchesCategoryFilter(const Pkg: TGetItPackageInfo): Boolean;
    function PackageMatchesTextFilter(const Pkg: TGetItPackageInfo): Boolean;
    function LatestGroupKeyForPackage(const Pkg: TGetItPackageInfo): string;
    function TryParsePackageTimestamp(const Pkg: TGetItPackageInfo; out TimeValue: TDateTime): Boolean;
    function IsPackageNewerByTimestamp(const CurrentPkg, CandidatePkg: TGetItPackageInfo): Boolean;
    function PadCell(const S: string; Width: Integer): string;
    procedure AddHeaderRowToList;
    procedure UpdateColumnWidths(const VisibleList: TList<TGetItPackageInfo>);
    procedure UpdateListHorizontalExtent;
    procedure RebuildVisiblePackageList;
    function IsRunningUnderDebugger: Boolean;
    function IsIdeProcessRunning: Boolean;
    function ShowIdeBlockedDialog: Boolean;
    procedure EnsureIdeClosedOrExit;
    function EnsureIdeClosedForInstall: Boolean;
    function FormatPackageRow(const Pkg: TGetItPackageInfo): string;
    function TryGetSelectedPackageInfo(out Pkg: TGetItPackageInfo): Boolean;
    function TryGetSelectedPackageWithLibUrl(out Pkg: TGetItPackageInfo): Boolean;
    procedure ParseAndAddPackageLine(const RawLine: string);
    procedure BuildUiEnhancements;
    procedure DownloadSelectedViaGetItCmd(Sender: TObject);
    procedure DownloadSelectedDirectRest(Sender: TObject);
    procedure LocalSortMenuClick(Sender: TObject);
    procedure UpdateLocalSortMenuVisibility;
    procedure UpdateGetItCmdSortOptionsForVersion;
    function GetItListArgFromRadio: string;
    procedure RefreshViaRest;
    procedure RefreshViaGetItCmd;
    procedure AddOrUpdatePackageInfo(const Id, Version, Description: string);
    procedure PopulateDescriptionFromPackageInfo(const Pkg: TGetItPackageInfo);
    function GetCategoryNameMapFromRegistry: TDictionary<string, string>;
    procedure FillMissingCategoryNamesFromRegistry;
    procedure UpdateGetItConnectionModeIndicator;
    procedure UpdateRestFilterControlsState;
    procedure LoadRADVersionsCombo;
    procedure CleanPackageList;
    procedure ProcessCheckedPackages(GetItArgsFunc: TGetItArgsFunction; const OperationLabel: string);
    function BDSRootPath(const BDSVersion: string): string;
    function BDSBinDir: string;
    function ParseGetItName(const GetItLine: string): string;
    function CountChecked: Integer;
    function SelectedBDSVersion: string;
    function IsPackageIndexValid: Boolean;
    property PackageCount: Integer write SetPackageCount;
    property DownloadTime: Integer write SetDownloadTime;
    property ExecLine: string write SetExecLine;
  end;

var
  frmMain: TfrmMain;


implementation

{$R *.dfm}

uses
  Winapi.Windows, Winapi.Messages, Winapi.TlHelp32, Vcl.Graphics, System.UITypes,
  System.SysUtils, System.Diagnostics, System.DateUtils, System.Math, System.Win.Registry,
  System.StrUtils, System.IOUtils, System.Net.HttpClient, System.Net.URLClient, Vcl.FileCtrl,
  ufrmInstallLog, ufrmOutputLog, uGetItCore, uGetItListModel, uGetItRestService;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FOutputLog := TStringList.Create;
  FOutputErrorDetected := False;
  FOutputWarningDetected := False;
  FTextFilterActive := False;
  FLocalSortIndex := 2; // Name
  FPackageInfoById := TObjectDictionary<string, TGetItPackageInfo>.Create([doOwnsValues]);
  FListSource := lsUnknown;
  UpdateOutputLogButtonState;

    StatusBar.Panels[0].Width := 250;
    StatusBar.Panels[1].Width := 250;
    StatusBar.Panels[2].Width := Max(200, StatusBar.ClientWidth - StatusBar.Panels[0].Width - StatusBar.Panels[1].Width - 24);

  BuildUiEnhancements;
  EnsureIdeClosedOrExit;
  LoadRADVersionsCombo;
  lbPackages.Items.Clear;
  UpdateInstallSelectedButtonState;
  UpdateGetItConnectionModeIndicator;
  UpdateRestFilterControlsState;
end;

procedure TfrmMain.UpdateGetItConnectionModeIndicator;
begin
  // Current UX choice: keep GetIt in online mode only.
  lblGetItMode.Caption := 'GetIt mode: Online';
  lblGetItMode.Font.Color := clGreen;
  btnToggleGetItMode.Caption := 'Online only';
  btnToggleGetItMode.Enabled := False;
end;

procedure TfrmMain.UpdateRestFilterControlsState;
var
  RestEnabled: Boolean;
begin
  RestEnabled := FListSource <> lsGetItCmd;

  FLblCategoryFilter.Enabled := RestEnabled;
  FCmbCategoryFilter.Enabled := RestEnabled and (FCmbCategoryFilter.Items.Count > 1);
  chkNotInstalledOnly.Enabled := RestEnabled;
  cbInstalledRest.Enabled := RestEnabled;
  lFilterRestList.Enabled := RestEnabled;
  FChkDelphiOnly.Enabled := RestEnabled;
  FChkLatestOnly.Enabled := RestEnabled;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FPackageInfoById.Free;
  FOutputLog.Free;
end;

procedure TfrmMain.BuildUiEnhancements;
begin
  edtNameFilter.OnChange := edtNameFilterChange;
  lFilterRestList.OnChange := edtNameFilterChange;


  rgrpSortBy.Items.BeginUpdate;
  try
    rgrpSortBy.Items.Clear;
    rgrpSortBy.Items.Add('Name');
    rgrpSortBy.Items.Add('Vendor');
    rgrpSortBy.Items.Add('Date');
    rgrpSortBy.Columns := 3;
    if (rgrpSortBy.ItemIndex < 0) or (rgrpSortBy.ItemIndex >= rgrpSortBy.Items.Count) then
      rgrpSortBy.ItemIndex := 0;
  finally
    rgrpSortBy.Items.EndUpdate;
  end;

  FChkDelphiOnly.Checked := True;
  FChkLatestOnly.Checked := True;
  FLblVersionState.Caption := 'Version check: n/a';
  ResetCategoryFilter;

  binstallselected.Caption := 'Install selected';
  binstallselected.Enabled := False;
  binstallselected.OnClick := binstallselectedClick;

  FMenuDownloadViaGetItCmd := TMenuItem.Create(mnuCheckListPopup);
  FMenuDownloadViaGetItCmd.Caption := 'Download highlighted (GetItCmd)';
  FMenuDownloadViaGetItCmd.OnClick := DownloadSelectedViaGetItCmd;
  mnuCheckListPopup.Items.Add(FMenuDownloadViaGetItCmd);

  FMenuDownloadDirectRest := TMenuItem.Create(mnuCheckListPopup);
  FMenuDownloadDirectRest.Caption := 'Download highlighted (REST direct...)';
  FMenuDownloadDirectRest.OnClick := DownloadSelectedDirectRest;
  mnuCheckListPopup.Items.Add(FMenuDownloadDirectRest);

  FMenuSortLocal := TMenuItem.Create(mnuCheckListPopup);
  FMenuSortLocal.Caption := 'Sort (local)';
  mnuCheckListPopup.Items.Add(FMenuSortLocal);

  FMenuSortId := TMenuItem.Create(FMenuSortLocal);
  FMenuSortId.Caption := 'ID';
  FMenuSortId.RadioItem := True;
  FMenuSortId.AutoCheck := True;
  FMenuSortId.Tag := 0;
  FMenuSortId.OnClick := LocalSortMenuClick;
  FMenuSortLocal.Add(FMenuSortId);

  FMenuSortVersion := TMenuItem.Create(FMenuSortLocal);
  FMenuSortVersion.Caption := 'Version';
  FMenuSortVersion.RadioItem := True;
  FMenuSortVersion.AutoCheck := True;
  FMenuSortVersion.Tag := 1;
  FMenuSortVersion.OnClick := LocalSortMenuClick;
  FMenuSortLocal.Add(FMenuSortVersion);

  FMenuSortName := TMenuItem.Create(FMenuSortLocal);
  FMenuSortName.Caption := 'Name';
  FMenuSortName.RadioItem := True;
  FMenuSortName.AutoCheck := True;
  FMenuSortName.Tag := 2;
  FMenuSortName.OnClick := LocalSortMenuClick;
  FMenuSortLocal.Add(FMenuSortName);

  FMenuSortVendor := TMenuItem.Create(FMenuSortLocal);
  FMenuSortVendor.Caption := 'Vendor';
  FMenuSortVendor.RadioItem := True;
  FMenuSortVendor.AutoCheck := True;
  FMenuSortVendor.Tag := 3;
  FMenuSortVendor.OnClick := LocalSortMenuClick;
  FMenuSortLocal.Add(FMenuSortVendor);

  FMenuSortCategory := TMenuItem.Create(FMenuSortLocal);
  FMenuSortCategory.Caption := 'Category';
  FMenuSortCategory.RadioItem := True;
  FMenuSortCategory.AutoCheck := True;
  FMenuSortCategory.Tag := 4;
  FMenuSortCategory.OnClick := LocalSortMenuClick;
  FMenuSortLocal.Add(FMenuSortCategory);

  FMenuSortDate := TMenuItem.Create(FMenuSortLocal);
  FMenuSortDate.Caption := 'Date';
  FMenuSortDate.RadioItem := True;
  FMenuSortDate.AutoCheck := True;
  FMenuSortDate.Tag := 5;
  FMenuSortDate.OnClick := LocalSortMenuClick;
  FMenuSortLocal.Add(FMenuSortDate);

  FMenuSortName.Checked := True;
  UpdateLocalSortMenuVisibility;
  UpdateRestFilterControlsState;
end;

//the lock is done to avoid IDE locked file
//debug run from IDE in not locked exept installation
function TfrmMain.IsIdeProcessRunning: Boolean;
var
  Snapshot: THandle;
  ProcEntry: TProcessEntry32;
begin
  Result := False;
  Snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Snapshot = INVALID_HANDLE_VALUE then
    Exit;
  try
    ProcEntry.dwSize := SizeOf(ProcEntry);
    if Process32First(Snapshot, ProcEntry) then
      repeat
        if SameText(ExtractFileName(string(ProcEntry.szExeFile)), 'BDS.exe') then
          Exit(True);
      until not Process32Next(Snapshot, ProcEntry);
  finally
    CloseHandle(Snapshot);
  end;
end;

function TfrmMain.IsRunningUnderDebugger: Boolean;
begin
  Result := IsDebuggerPresent;
end;

function TfrmMain.ShowIdeBlockedDialog: Boolean;
begin
  Result := MessageDlg(
    'Close RAD Studio before continue.' + sLineBreak + '(BDS.exe loaded).',
    mtWarning,
    [mbRetry, mbCancel],
    0) = mrRetry;
end;

procedure TfrmMain.EnsureIdeClosedOrExit;
begin
  if IsRunningUnderDebugger then
    Exit;

  while IsIdeProcessRunning do
    if not ShowIdeBlockedDialog then
      Halt(0);
end;

function TfrmMain.EnsureIdeClosedForInstall: Boolean;
begin
  Result := not IsIdeProcessRunning;
  if not Result then
    ShowMessage('Install not available: close RAD Studio (BDS.exe).');
end;

procedure TfrmMain.AppendOutputLog(const LogMsg: string);
begin
  FOutputLog.Add(LogMsg);

  if TGetItCore.IsLikelyErrorText(LogMsg) then
    SetOutputErrorDetected(True)
  else if TGetItCore.IsLikelyWarningText(LogMsg) then
    SetOutputWarningDetected(True);

  if frmOutputLog.Visible then
    frmOutputLog.AppendLogLine(LogMsg);
end;

procedure TfrmMain.UpdateOutputLogButtonState;
begin
  if FOutputErrorDetected then
  begin
    btnOutputLog.Font.Color := clRed;
    btnOutputLog.Hint := 'Output log (error detected)';
  end
  else if FOutputWarningDetected then
  begin
    btnOutputLog.Font.Color := clOlive;
    btnOutputLog.Hint := 'Output log (warning detected)';
  end
  else
  begin
    btnOutputLog.Font.Color := clWindowText;
    btnOutputLog.Hint := 'Output log';
  end;
end;

procedure TfrmMain.SetOutputErrorDetected(const Value: Boolean);
begin
  if FOutputErrorDetected = Value then
    Exit;

  FOutputErrorDetected := Value;
  UpdateOutputLogButtonState;
end;

procedure TfrmMain.SetOutputWarningDetected(const Value: Boolean);
begin
  if FOutputWarningDetected = Value then
    Exit;

  FOutputWarningDetected := Value;
  UpdateOutputLogButtonState;
end;

procedure TfrmMain.ResetListParserState;
begin
  FPastFirstItem := False;
  FFinished := False;
  FPackageNewLine := EmptyStr;
end;

procedure TfrmMain.FlushCurrentPackageLine;
begin
  if (not FPackageNewLine.IsEmpty) and (lbPackages.Items.IndexOf(FPackageNewLine) = -1) then
    lbPackages.Items.Add(FPackageNewLine);
  FPackageNewLine := EmptyStr;
end;

procedure TfrmMain.ParseGetItOutputLine(const ANewLine: string; AOutputType: TOutputType;
                                                  const AddToLog: Boolean);
begin
  if AOutputType <> otEntireLine then
    Exit;

  if AddToLog then
    AppendOutputLog(ANewLine);

  if TGetItCore.IsLikelyErrorText(ANewLine) then
    SetOutputErrorDetected(True);
  if TGetItCore.IsLikelyWarningText(ANewLine) then
    SetOutputWarningDetected(True);

  if not FPastFirstItem then
  begin
    if StartsText('--', ANewLine) then
      FPastFirstItem := True;
    Exit;
  end;

  if ContainsText(ANewLine, 'command finished') or ContainsText(ANewLine, 'command failed') then
  begin
    FFinished := True;
    FlushCurrentPackageLine;
    Exit;
  end;

  if FFinished or (Trim(ANewLine).Length = 0) then
    Exit;

  if ANewLine.Contains('  ') then
  begin
    FlushCurrentPackageLine;
    FPackageNewLine := ANewLine;
  end
  else
    FPackageNewLine := FPackageNewLine + ANewLine;
end;

function TfrmMain.IsPackageIndexValid: Boolean;
begin
  Result := (lbPackages.ItemIndex > 0) and (lbPackages.ItemIndex < lbPackages.Items.Count);
end;

procedure TfrmMain.lbPackagesClick(Sender: TObject);
begin
  if IsPackageIndexValid then begin
    actInstallOne.Enabled := True;
    actUninstallOne.Enabled := True;

    var Pkg: TGetItPackageInfo;
    if TryGetSelectedPackageInfo(Pkg) then
      PopulateDescriptionFromPackageInfo(Pkg)
    else
      mmoDescription.Text := lbPackages.Items[lbPackages.ItemIndex];

    if actInstallOne.Enabled then begin
      actInstallOne.Caption := 'Install ' + GetPackageIdFromItemIndex(lbPackages.ItemIndex);
      actUninstallOne.Caption := 'Uninstall ' + GetPackageIdFromItemIndex(lbPackages.ItemIndex);
    end else begin
      actInstallOne.Caption := 'Install ...';
      actUninstallOne.Caption := 'Uninstall ...';
    end;
  end else begin
    actInstallOne.Enabled := False;
    actUninstallOne.Enabled := False;
    mmoDescription.Clear;
  end;

  UpdateInstallSelectedButtonState;
end;

procedure TfrmMain.binstallselectedClick(Sender: TObject);
begin
  if not IsPackageIndexValid then
    Exit;

  actInstallOneExecute(Sender);
end;

procedure TfrmMain.PopulateDescriptionFromPackageInfo(const Pkg: TGetItPackageInfo);
begin
  mmoDescription.Lines.BeginUpdate;
  try
    mmoDescription.Lines.Clear;
    mmoDescription.Lines.Add('ID: ' + Pkg.Id);
    mmoDescription.Lines.Add('Version: ' + Pkg.Version);
    mmoDescription.Lines.Add('Name: ' + Pkg.Name);
    mmoDescription.Lines.Add('InstalledVersion: ' + Pkg.InstalledVersion);
    mmoDescription.Lines.Add('LatestVersion: ' + Pkg.LatestVersion);
    mmoDescription.Lines.Add('VersionStatus: ' + Pkg.VersionStatus);

    if FListSource = lsRest then
    begin
      mmoDescription.Lines.Add('Vendor: ' + Pkg.Vendor);
      mmoDescription.Lines.Add('VersionTimestamp: ' + Pkg.VersionTimestamp);
      mmoDescription.Lines.Add('Modified: ' + Pkg.Modified);
      mmoDescription.Lines.Add('Type: ' + Pkg.TypeDescription);
      mmoDescription.Lines.Add('LibCode: ' + Pkg.LibCode);
      mmoDescription.Lines.Add('LibCodeName: ' + Pkg.LibCodeName);
      mmoDescription.Lines.Add('State: ' + Pkg.State);
      mmoDescription.Lines.Add('Subscription: ' + Pkg.Subscription);
      mmoDescription.Lines.Add('CategoryIds: ' + Pkg.CategoryIds);
      mmoDescription.Lines.Add('CategoryNames: ' + Pkg.CategoryNames);
      mmoDescription.Lines.Add('LibSize: ' + Pkg.LibSize);
      mmoDescription.Lines.Add('LibUrl: ' + Pkg.LibUrl);
      mmoDescription.Lines.Add('VendorUrl: ' + Pkg.VendorUrl);
    end;

    mmoDescription.Lines.Add('');
    mmoDescription.Lines.Add('Description:');
    mmoDescription.Lines.Add(Pkg.Description);
  finally
    mmoDescription.Lines.EndUpdate;
  end;
end;

function TfrmMain.TryGetSelectedPackageInfo(out Pkg: TGetItPackageInfo): Boolean;
begin
  if not IsPackageIndexValid then
  begin
    Pkg := nil;
    Exit(False);
  end;
  Result := PackageInfoFromItemIndex(lbPackages.ItemIndex, Pkg);
end;

function TfrmMain.TryGetSelectedPackageWithLibUrl(out Pkg: TGetItPackageInfo): Boolean;
begin
  Result := False;
  if not TryGetSelectedPackageInfo(Pkg) then
  begin
    ShowMessage('No package selected.');
    Exit;
  end;

  if Pkg.LibUrl.IsEmpty then
  begin
    ShowMessage('No LibUrl available for selected package.');
    Exit;
  end;

  Result := True;
end;

procedure TfrmMain.ParseAndAddPackageLine(const RawLine: string);
var
  PackageId: string;
  PackageVer: string;
  PackageDesc: string;
begin
  PackageId := Trim(Copy(RawLine, 1, 50));
  PackageVer := Trim(Copy(RawLine, 51, 16));
  PackageDesc := Trim(Copy(RawLine, 67, MaxInt));
  AddOrUpdatePackageInfo(PackageId, PackageVer, PackageDesc);
end;


procedure TfrmMain.ApplyMutuallyExclusiveFilter(const ChangedFilter: TCheckBox);
begin
  if ChangedFilter = chkInstalledOnly then
  begin
    // GetItCmd-specific filter: no mutual exclusion with REST controls.
  end
  else if ChangedFilter = cbInstalledRest then
  begin
    if cbInstalledRest.Checked then
      chkNotInstalledOnly.Checked := False;
  end
  else if ChangedFilter = chkNotInstalledOnly then
  begin
    if chkNotInstalledOnly.Checked then
      cbInstalledRest.Checked := False;
  end;

  if (FPackageInfoById.Count > 0) and (FListSource = lsRest) then
    RebuildVisiblePackageList;
end;

procedure TfrmMain.UpdateInstallSelectedButtonState;
begin
  binstallselected.Enabled := IsPackageIndexValid;
end;

function TfrmMain.VisiblePackageCount: Integer;
begin
  Result := Max(0, lbPackages.Items.Count - 1);
end;

procedure TfrmMain.UpdatePackageActionsState;
var
  HasPackages: Boolean;
begin
  PackageCount := VisiblePackageCount;
  HasPackages := VisiblePackageCount > 0;

  actInstallChecked.Enabled := HasPackages;
  actUninstallChecked.Enabled := HasPackages;
  UpdateInstallSelectedButtonState;

  FMenuDownloadViaGetItCmd.Enabled := HasPackages;
  FMenuDownloadDirectRest.Enabled := HasPackages;
end;

procedure TfrmMain.ResetCategoryFilter;
begin
  FCmbCategoryFilter.Items.BeginUpdate;
  try
    FCmbCategoryFilter.Items.Clear;
    FCmbCategoryFilter.Items.Add('All');
    FCmbCategoryFilter.ItemIndex := 0;
    FCmbCategoryFilter.Enabled := False;
  finally
    FCmbCategoryFilter.Items.EndUpdate;
  end;
end;

procedure TfrmMain.UpdateCategoryFilterItems;
var
  PrevSelection: string;
  Categories: TStringList;
  Tokens: TStringList;

  procedure AddCategoryToken(const Token: string; const FromIds: Boolean);
  var
    DisplayToken: string;
  begin
    DisplayToken := Trim(Token);
    if DisplayToken = '' then
      Exit;
    if FromIds then
      DisplayToken := '#' + DisplayToken;
    if Categories.IndexOf(DisplayToken) = -1 then
      Categories.Add(DisplayToken);
  end;

  procedure AddCsvTokens(const Csv: string; const FromIds: Boolean);
  begin
    Tokens.DelimitedText := StringReplace(Csv, ', ', ',', [rfReplaceAll]);
    for var i := 0 to Tokens.Count - 1 do
      AddCategoryToken(Tokens[i], FromIds);
  end;
begin
  PrevSelection := '';
  if FCmbCategoryFilter.ItemIndex >= 0 then
    PrevSelection := FCmbCategoryFilter.Items[FCmbCategoryFilter.ItemIndex];

  Categories := TStringList.Create;
  Tokens := TStringList.Create;
  try
    Categories.Sorted := True;
    Categories.Duplicates := dupIgnore;

    Tokens.Delimiter := ',';
    Tokens.StrictDelimiter := True;

    for var Pair in FPackageInfoById do
    begin
      var Pkg := Pair.Value;
      if Pkg = nil then
        Continue;

      if (FListSource = lsRest) and FChkDelphiOnly.Checked and
         (not TGetItListModel.IsDelphiPackage(Pkg)) then
        Continue;

      if Pkg.CategoryNames <> '' then
        AddCsvTokens(Pkg.CategoryNames, False)
      else if Pkg.CategoryIds <> '' then
        AddCsvTokens(Pkg.CategoryIds, True);
    end;

    FCmbCategoryFilter.Items.BeginUpdate;
    try
      FCmbCategoryFilter.Items.Clear;
      FCmbCategoryFilter.Items.Add('All');
      for var i := 0 to Categories.Count - 1 do
        FCmbCategoryFilter.Items.Add(Categories[i]);

      if (PrevSelection <> '') and (FCmbCategoryFilter.Items.IndexOf(PrevSelection) >= 0) then
        FCmbCategoryFilter.ItemIndex := FCmbCategoryFilter.Items.IndexOf(PrevSelection)
      else
        FCmbCategoryFilter.ItemIndex := 0;

      FCmbCategoryFilter.Enabled := FCmbCategoryFilter.Items.Count > 1;
    finally
      FCmbCategoryFilter.Items.EndUpdate;
    end;
  finally
    Tokens.Free;
    Categories.Free;
  end;
end;

function TfrmMain.PackageMatchesCategoryFilter(const Pkg: TGetItPackageInfo): Boolean;
var
  Selected: string;
  Tokens: TStringList;
  MatchToken: string;
begin
  if FCmbCategoryFilter.ItemIndex <= 0 then
    Exit(True);

  Selected := Trim(FCmbCategoryFilter.Items[FCmbCategoryFilter.ItemIndex]);
  if Selected = '' then
    Exit(True);

  if SameText(Selected, 'All') then
    Exit(True);

  Tokens := TStringList.Create;
  try
    Tokens.Delimiter := ',';
    Tokens.StrictDelimiter := True;

    if Selected.StartsWith('#') then
    begin
      if Pkg.CategoryIds = '' then
        Exit(False);
      MatchToken := Selected.Substring(1);
      Tokens.DelimitedText := StringReplace(Pkg.CategoryIds, ', ', ',', [rfReplaceAll]);
    end
    else
    begin
      if Pkg.CategoryNames = '' then
        Exit(False);
      MatchToken := Selected;
      Tokens.DelimitedText := StringReplace(Pkg.CategoryNames, ', ', ',', [rfReplaceAll]);
    end;

    for var i := 0 to Tokens.Count - 1 do
      if SameText(Trim(Tokens[i]), MatchToken) then
        Exit(True);
  finally
    Tokens.Free;
  end;

  Result := False;
end;

function TfrmMain.PackageMatchesTextFilter(const Pkg: TGetItPackageInfo): Boolean;
var
  FilterText: string;
begin
  if FListSource <> lsRest then
    Exit(True);

  FilterText := Trim(lFilterRestList.Text);
  if Length(FilterText) < TEXT_FILTER_MIN_CHARS then
    Exit(True);

  Result := ContainsText(Pkg.Name, FilterText) or
            ContainsText(Pkg.Description, FilterText) or
            ContainsText(Pkg.Id, FilterText);
end;

function TfrmMain.LatestGroupKeyForPackage(const Pkg: TGetItPackageInfo): string;
var
  BaseId: string;
  VendorKey: string;
  LibCodeKey: string;
begin
  BaseId := TGetItCore.NormalizePackageKey(Pkg.Id);
  if BaseId = '' then
    BaseId := Trim(LowerCase(Pkg.Id));

  VendorKey := Trim(LowerCase(Pkg.Vendor));

  LibCodeKey := Trim(LowerCase(Pkg.LibCode));
  if LibCodeKey = '' then
    LibCodeKey := Trim(LowerCase(Pkg.LibCodeName));

  Result := BaseId + '|' + VendorKey + '|' + LibCodeKey;
end;

function TfrmMain.TryParsePackageTimestamp(const Pkg: TGetItPackageInfo; out TimeValue: TDateTime): Boolean;
var
  TimestampText: string;
begin
  TimestampText := Trim(Pkg.VersionTimestamp);
  Result := TryISO8601ToDate(TimestampText, TimeValue) or
            TryStrToDateTime(TimestampText, TimeValue);

  if Result then
    Exit;

  TimestampText := Trim(Pkg.Modified);
  Result := TryISO8601ToDate(TimestampText, TimeValue) or
            TryStrToDateTime(TimestampText, TimeValue);
end;

function TfrmMain.IsPackageNewerByTimestamp(const CurrentPkg, CandidatePkg: TGetItPackageInfo): Boolean;
var
  CurrentTime, CandidateTime: TDateTime;
  HasCurrentTime, HasCandidateTime: Boolean;
  VersionCmp: Integer;
begin
  HasCurrentTime := TryParsePackageTimestamp(CurrentPkg, CurrentTime);
  HasCandidateTime := TryParsePackageTimestamp(CandidatePkg, CandidateTime);

  if HasCandidateTime and HasCurrentTime then
  begin
    if CandidateTime > CurrentTime then
      Exit(True);
    if CandidateTime < CurrentTime then
      Exit(False);
  end
  else if HasCandidateTime and (not HasCurrentTime) then
    Exit(True)
  else if HasCurrentTime and (not HasCandidateTime) then
    Exit(False);

  VersionCmp := TGetItCore.CompareVersionText(CurrentPkg.Version, CandidatePkg.Version);
  if VersionCmp < 0 then
    Exit(True);
  if VersionCmp > 0 then
    Exit(False);

  Result := CompareText(CurrentPkg.Id, CandidatePkg.Id) > 0;
end;

function TfrmMain.BuildListHeaderRow: string;
begin
  if FListSource = lsRest then
    Result := PadCell('ID', FColWidthId) + ' | ' +
              PadCell('Version', FColWidthVersion) + ' | ' +
              PadCell('Name', FColWidthName) + ' | ' +
              PadCell('Vendor', FColWidthVendor) + ' | ' +
              PadCell('Type', FColWidthType) + ' | ' +
              PadCell('Category', FColWidthSub) + ' | ' +
              PadCell('Size', FColWidthSize) + ' | ' +
              PadCell('Status', FColWidthStatus)
  else
    Result := PadCell('ID', FColWidthId) + ' | ' +
              PadCell('Version', FColWidthVersion) + ' | ' +
              PadCell('Name', FColWidthName) + ' | ' +
              PadCell('Status', FColWidthStatus);
end;

function TfrmMain.PackageInfoFromItemIndex(const Index: Integer; out Pkg: TGetItPackageInfo): Boolean;
begin
  Pkg := nil;
  Result := False;
  if (Index < 0) or (Index >= lbPackages.Items.Count) then
    Exit;

  if lbPackages.Items.Objects[Index] is TGetItPackageInfo then
  begin
    Pkg := TGetItPackageInfo(lbPackages.Items.Objects[Index]);
    Exit(True);
  end;

  Result := FPackageInfoById.TryGetValue(ParseGetItName(lbPackages.Items[Index]), Pkg);
end;

function TfrmMain.GetPackageIdFromItemIndex(const Index: Integer): string;
var
  Pkg: TGetItPackageInfo;
begin
  if PackageInfoFromItemIndex(Index, Pkg) then
    Exit(Pkg.Id);
  Result := ParseGetItName(lbPackages.Items[Index]);
end;

function TfrmMain.StatusTextForPackage(const Pkg: TGetItPackageInfo): string;
begin
  if SameText(Pkg.VersionStatus, 'Installed') then
    Exit('Installed ' + Pkg.InstalledVersion);
  if SameText(Pkg.VersionStatus, 'Outdated') then
    Exit('Outdated ' + Pkg.InstalledVersion + '->' + Pkg.LatestVersion);
  Result := 'Not installed';
end;

function TfrmMain.CategoryTextForPackage(const Pkg: TGetItPackageInfo): string;
begin
  if Pkg = nil then
    Exit('-');

  if Pkg.CategoryNames <> '' then
    Exit(Pkg.CategoryNames);

  if Pkg.CategoryIds <> '' then
    Exit('#' + Pkg.CategoryIds);

  Result := '-';
end;

function TfrmMain.PadCell(const S: string; Width: Integer): string;
var
  PadLen: Integer;
begin
  if Width <= 0 then
    Exit(S);
  PadLen := Width - Length(S);
  if PadLen > 0 then
    Result := S + StringOfChar(' ', PadLen)
  else
    Result := S;
end;

procedure TfrmMain.AddHeaderRowToList;
begin
  lbPackages.Items.Insert(0, BuildListHeaderRow);
  lbPackages.State[0] := Vcl.StdCtrls.cbGrayed;
  lbPackages.ItemEnabled[0] := False;
end;

procedure TfrmMain.UpdateColumnWidths(const VisibleList: TList<TGetItPackageInfo>);
begin
  FColWidthId := Length('ID');
  FColWidthVersion := Length('Version');
  FColWidthName := Length('Name');
  FColWidthStatus := Length('Status');

  if FListSource = lsRest then
  begin
    FColWidthVendor := Length('Vendor');
    FColWidthType := Length('Type');
    FColWidthSub := Length('Category');
    FColWidthSize := Length('Size');
  end
  else
  begin
    FColWidthVendor := 0;
    FColWidthType := 0;
    FColWidthSub := 0;
    FColWidthSize := 0;
  end;

  for var Pkg in VisibleList do
  begin
    if Length(Pkg.Id) > FColWidthId then
      FColWidthId := Length(Pkg.Id);
    if Length(Pkg.Version) > FColWidthVersion then
      FColWidthVersion := Length(Pkg.Version);
    if Length(Pkg.Name) > FColWidthName then
      FColWidthName := Length(Pkg.Name);
    if FListSource = lsRest then
    begin
      if Length(Pkg.Vendor) > FColWidthVendor then
        FColWidthVendor := Length(Pkg.Vendor);
      if Length(Pkg.TypeDescription) > FColWidthType then
        FColWidthType := Length(Pkg.TypeDescription);
      var CategoryText := CategoryTextForPackage(Pkg);
      if Length(CategoryText) > FColWidthSub then
        FColWidthSub := Length(CategoryText);
      if Length(Pkg.LibSize) > FColWidthSize then
        FColWidthSize := Length(Pkg.LibSize);
    end;
    var StatusText := StatusTextForPackage(Pkg);
    if Length(StatusText) > FColWidthStatus then
      FColWidthStatus := Length(StatusText);
  end;
end;

procedure TfrmMain.UpdateListHorizontalExtent;
var
  MaxTextWidth: Integer;
begin
  MaxTextWidth := lbPackages.Canvas.TextWidth(BuildListHeaderRow);
  for var i := 0 to lbPackages.Items.Count - 1 do
    MaxTextWidth := Max(MaxTextWidth, lbPackages.Canvas.TextWidth(lbPackages.Items[i]));

  lbPackages.ScrollWidth := MaxTextWidth + 24;
  SendMessage(lbPackages.Handle, LB_SETHORIZONTALEXTENT, lbPackages.ScrollWidth, 0);
end;

procedure TfrmMain.RebuildVisiblePackageList;
var
  LatestByKey: TDictionary<string, TGetItPackageInfo>;
  VisibleList: TList<TGetItPackageInfo>;
  InstalledIds: TDictionary<string, Byte>;
  DelphiOnly: Boolean;
  LatestOnly: Boolean;
  IsRestSource: Boolean;
  Key: string;
  Current: TGetItPackageInfo;
begin
  IsRestSource := FListSource = lsRest;
  DelphiOnly := IsRestSource and FChkDelphiOnly.Checked;
  LatestOnly := IsRestSource and FChkLatestOnly.Checked;

  LatestByKey := nil;
  if LatestOnly then
    LatestByKey := TDictionary<string, TGetItPackageInfo>.Create;
  VisibleList := TList<TGetItPackageInfo>.Create;
  InstalledIds := nil;
  try
    if IsRestSource and (cbInstalledRest.Checked or chkNotInstalledOnly.Checked) then
      InstalledIds := GetInstalledPackageIdsFromRegistry;

    for var Pair in FPackageInfoById do
    begin
      var Pkg := Pair.Value;
      if (FListSource = lsRest) and DelphiOnly and (not TGetItListModel.IsDelphiPackage(Pkg)) then
        Continue;

      if (InstalledIds <> nil) and
         (not TGetItListModel.ShouldIncludeByInstalledFilter(Pkg, InstalledIds, cbInstalledRest.Checked, chkNotInstalledOnly.Checked)) then
        Continue;
      if IsRestSource and (not PackageMatchesCategoryFilter(Pkg)) then
        Continue;
      if not PackageMatchesTextFilter(Pkg) then
        Continue;

      if LatestOnly then
      begin
        Key := LatestGroupKeyForPackage(Pkg);

        if LatestByKey.TryGetValue(Key, Current) then
        begin
          if IsPackageNewerByTimestamp(Current, Pkg) then
            LatestByKey[Key] := Pkg;
        end
        else
          LatestByKey.Add(Key, Pkg);
      end
      else
        VisibleList.Add(Pkg);
    end;

    if LatestOnly then
      for var Pair in LatestByKey do
        VisibleList.Add(Pair.Value);

    VisibleList.Sort(TComparer<TGetItPackageInfo>.Construct(
      function(const Left, Right: TGetItPackageInfo): Integer
      begin
        case FLocalSortIndex of
          1: Result := TGetItCore.CompareVersionText(Right.Version, Left.Version);
          2: Result := CompareText(Left.Name, Right.Name);
          3: Result := CompareText(Left.Vendor, Right.Vendor);
          4: Result := CompareText(CategoryTextForPackage(Left), CategoryTextForPackage(Right));
          5: Result := TGetItListModel.ComparePackageDate(Left, Right);
        else
          Result := CompareText(Left.Id, Right.Id);
        end;
        if Result = 0 then
          Result := CompareText(Left.Id, Right.Id);
      end));

    UpdateColumnWidths(VisibleList);
    lbPackages.Items.BeginUpdate;
    try
      lbPackages.Items.Clear;
      AddHeaderRowToList;
      for var Pkg in VisibleList do
        lbPackages.Items.AddObject(FormatPackageRow(Pkg), Pkg);
    finally
      lbPackages.Items.EndUpdate;
    end;


    UpdateVersionStatusAndLabel;
    UpdateColumnWidths(VisibleList);
    for var i := 1 to lbPackages.Items.Count - 1 do
      if lbPackages.Items.Objects[i] is TGetItPackageInfo then
        lbPackages.Items[i] := FormatPackageRow(TGetItPackageInfo(lbPackages.Items.Objects[i]));

    UpdateListHorizontalExtent;
    UpdateInstallSelectedButtonState;
  finally
    InstalledIds.Free;
    VisibleList.Free;
    LatestByKey.Free;
  end;
end;

function TfrmMain.GetInstalledPackageIdsFromRegistry: TDictionary<string, Byte>;
var
  Reg: TRegistry;
  Keys: TStringList;
  procedure AddKey(const RawKey: string);
  var
    Key: string;
  begin
    Key := Trim(LowerCase(RawKey));
    if (Key <> '') and (not Result.ContainsKey(Key)) then
      Result.Add(Key, 1);
  end;
  procedure AddFromPackages37(const CatalogRoot: string);
  var
    ItemId: string;
    VerKeys: TStringList;
  begin
    if not Reg.OpenKeyReadOnly(CatalogRoot + '\Packages') then
      Exit;

    Keys.Clear;
    Reg.GetKeyNames(Keys);
    for var i := 0 to Keys.Count - 1 do
    begin
      var PkgKey := Keys[i];
      var VerRoot := CatalogRoot + '\Packages\' + PkgKey + '\Versions';
      if not Reg.OpenKeyReadOnly(VerRoot) then
        Continue;

      VerKeys := TStringList.Create;
      try
        Reg.GetKeyNames(VerKeys);
        for var v := 0 to VerKeys.Count - 1 do
        begin
          var VerKey := VerKeys[v];
          var FullVerKey := VerRoot + '\' + VerKey;
          if not Reg.OpenKeyReadOnly(FullVerKey) then
            Continue;

          if Reg.ValueExists('Installed') and (Reg.ReadInteger('Installed') = 0) then
            Continue;
          if not Reg.ValueExists('Version') then
            Continue;

          ItemId := '';
          if Reg.ValueExists('Id') then
            ItemId := Trim(Reg.ReadString('Id'));
          if ItemId = '' then
            Continue;

          AddKey(ItemId);
        end;
      finally
        VerKeys.Free;
      end;
    end;
  end;
  procedure AddFromElementsLegacy(const CatalogRoot: string);
  var
    ItemId: string;
  begin
    if not Reg.OpenKeyReadOnly(CatalogRoot + '\Elements') then
      Exit;

    Keys.Clear;
    Reg.GetKeyNames(Keys);
    for var i := 0 to Keys.Count - 1 do
    begin
      var ElementKey := CatalogRoot + '\Elements\' + Keys[i];
      if not Reg.OpenKeyReadOnly(ElementKey) then
        Continue;

      if Reg.ValueExists('Installed') and (Reg.ReadInteger('Installed') = 0) then
        Continue;
      if not Reg.ValueExists('Version') then
        Continue;

      ItemId := Keys[i];
      AddKey(ItemId);
    end;
  end;
  procedure ScanInstalledForHive(const HiveRoot: HKEY; const BDSRoot: string);
  var
    CatalogRoot: string;
  begin
    Reg.RootKey := HiveRoot;
    CatalogRoot := BDSRoot + SelectedBDSVersion + '\CatalogRepository';
    if SelectedBDSVersion = '37.0' then
      AddFromPackages37(CatalogRoot)
    else
      AddFromElementsLegacy(CatalogRoot);
  end;
begin
  Result := TDictionary<string, Byte>.Create;
  Reg := TRegistry.Create(KEY_READ);
  Keys := TStringList.Create;
  try
    ScanInstalledForHive(HKEY_CURRENT_USER, BDS_USER_ROOT);
    ScanInstalledForHive(HKEY_LOCAL_MACHINE, BDS_MACHINE_WOW6432_ROOT);
  finally
    Keys.Free;
    Reg.Free;
  end;
end;

function TfrmMain.GetInstalledPackageVersionsFromRegistry: TDictionary<string, string>;
var
  Reg: TRegistry;
  Keys: TStringList;
  procedure AddVersion(const PackageKey, Version: string);
  var
    Key: string;
    Current: string;
  begin
    Key := Trim(LowerCase(PackageKey));
    if Key = '' then
      Exit;
    if not Result.TryGetValue(Key, Current) then
      Result.Add(Key, Version)
    else if TGetItCore.CompareVersionText(Current, Version) < 0 then
      Result[Key] := Version;
  end;
  procedure ReadPackages37(const CatalogRoot: string);
  begin
    if not Reg.OpenKeyReadOnly(CatalogRoot + '\Packages') then
      Exit;

    Reg.GetKeyNames(Keys);
    for var i := 0 to Keys.Count - 1 do
    begin
      var PkgKey := Keys[i];
      var VerRoot := CatalogRoot + '\Packages\' + PkgKey + '\Versions';
      if not Reg.OpenKeyReadOnly(VerRoot) then
        Continue;

      var VerKeys := TStringList.Create;
      try
        Reg.GetKeyNames(VerKeys);
        for var v := 0 to VerKeys.Count - 1 do
        begin
          var VerKey := VerKeys[v];
          var FullVerKey := VerRoot + '\' + VerKey;
          if not Reg.OpenKeyReadOnly(FullVerKey) then
            Continue;

          if Reg.ValueExists('Installed') and (Reg.ReadInteger('Installed') = 0) then
            Continue;
          if not Reg.ValueExists('Version') then
            Continue;

          var Version := Trim(Reg.ReadString('Version'));
          var ItemId := '';
          if Reg.ValueExists('Id') then
            ItemId := Trim(Reg.ReadString('Id'));
          if ItemId = '' then
            Continue;

          AddVersion(ItemId, Version);
        end;
      finally
        VerKeys.Free;
      end;
    end;
  end;
  procedure ReadElementsLegacy(const CatalogRoot: string);
  begin
    if not Reg.OpenKeyReadOnly(CatalogRoot + '\Elements') then
      Exit;

    Keys.Clear;
    Reg.GetKeyNames(Keys);
    for var i := 0 to Keys.Count - 1 do
    begin
      var ElementKey := CatalogRoot + '\Elements\' + Keys[i];
      if not Reg.OpenKeyReadOnly(ElementKey) then
        Continue;
      if Reg.ValueExists('Installed') and (Reg.ReadInteger('Installed') = 0) then
        Continue;
      if not Reg.ValueExists('Version') then
        Continue;

      AddVersion(Keys[i], Trim(Reg.ReadString('Version')));
    end;
  end;
  procedure ScanVersionsForHive(const HiveRoot: HKEY; const BDSRoot: string);
  var
    CatalogRoot: string;
  begin
    Reg.RootKey := HiveRoot;
    CatalogRoot := BDSRoot + SelectedBDSVersion + '\CatalogRepository';
    if SelectedBDSVersion = '37.0' then
      ReadPackages37(CatalogRoot)
    else
      ReadElementsLegacy(CatalogRoot);
  end;
begin
  Result := TDictionary<string, string>.Create;
  Reg := TRegistry.Create(KEY_READ);
  Keys := TStringList.Create;
  try
    ScanVersionsForHive(HKEY_CURRENT_USER, BDS_USER_ROOT);
    ScanVersionsForHive(HKEY_LOCAL_MACHINE, BDS_MACHINE_WOW6432_ROOT);
  finally
    Keys.Free;
    Reg.Free;
  end;
end;

function TfrmMain.GetCategoryNameMapFromRegistry: TDictionary<string, string>;
var
  Reg: TRegistry;
  RootKey: string;
  CategoryKeys: TStringList;
  ValueNames: TStringList;
  CategoryId: string;
  CategoryName: string;
begin
  Result := TDictionary<string, string>.Create;
  Reg := TRegistry.Create(KEY_READ);
  CategoryKeys := TStringList.Create;
  ValueNames := TStringList.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    RootKey := BDS_USER_ROOT + SelectedBDSVersion + '\CatalogRepository\Categories';

    if not Reg.OpenKeyReadOnly(RootKey) then
      Exit;

    Reg.GetKeyNames(CategoryKeys);
    for var i := 0 to CategoryKeys.Count - 1 do
    begin
      CategoryId := Trim(CategoryKeys[i]);
      if CategoryId = '' then
        Continue;

      CategoryName := '';
      if Reg.OpenKeyReadOnly(RootKey + '\' + CategoryId) then
      begin
        if Reg.ValueExists('Name') then
          CategoryName := Trim(Reg.ReadString('Name'));

        if CategoryName = '' then
        begin
          ValueNames.Clear;
          Reg.GetValueNames(ValueNames);
          for var v := 0 to ValueNames.Count - 1 do
          begin
            var ValueName := ValueNames[v];
            if Reg.GetDataType(ValueName) <> rdString then
              Continue;

            CategoryName := Trim(Reg.ReadString(ValueName));
            if CategoryName <> '' then
              Break;
          end;
        end;
      end;

      if (CategoryName <> '') and (not Result.ContainsKey(CategoryId)) then
        Result.Add(CategoryId, CategoryName);
    end;
  finally
    ValueNames.Free;
    CategoryKeys.Free;
    Reg.Free;
  end;
end;

procedure TfrmMain.FillMissingCategoryNamesFromRegistry;
var
  CategoryMap: TDictionary<string, string>;
  CategoryIds: TStringList;
  ResolvedNames: string;
begin
  CategoryMap := GetCategoryNameMapFromRegistry;
  try
    if CategoryMap.Count = 0 then
      Exit;

    CategoryIds := TStringList.Create;
    try
      CategoryIds.Delimiter := ',';
      CategoryIds.StrictDelimiter := True;

      for var Pair in FPackageInfoById do
      begin
        var Pkg := Pair.Value;
        if (Pkg = nil) or (Pkg.CategoryIds = '') or (Pkg.CategoryNames <> '') then
          Continue;

        CategoryIds.DelimitedText := StringReplace(Pkg.CategoryIds, ', ', ',', [rfReplaceAll]);
        ResolvedNames := '';

        for var i := 0 to CategoryIds.Count - 1 do
        begin
          var CategoryId := Trim(CategoryIds[i]);
          if CategoryId = '' then
            Continue;

          var CategoryName := '';
          if CategoryMap.TryGetValue(CategoryId, CategoryName) and (CategoryName <> '') then
          begin
            if ResolvedNames <> '' then
              ResolvedNames := ResolvedNames + ', ';
            ResolvedNames := ResolvedNames + CategoryName;
          end;
        end;

        if ResolvedNames <> '' then
          Pkg.CategoryNames := ResolvedNames;
      end;
    finally
      CategoryIds.Free;
    end;
  finally
    CategoryMap.Free;
  end;
end;

procedure TfrmMain.UpdateVersionStatusAndLabel;
var
  InstalledIds: TDictionary<string, Byte>;
  InstalledVersions: TDictionary<string, string>;
  VisiblePackages: TList<TGetItPackageInfo>;
  OutdatedCount, InstalledCount: Integer;
begin
  InstalledIds := GetInstalledPackageIdsFromRegistry;
  InstalledVersions := GetInstalledPackageVersionsFromRegistry;
  VisiblePackages := TList<TGetItPackageInfo>.Create;
  try
    for var i := 1 to lbPackages.Items.Count - 1 do
    begin
      if lbPackages.Items.Objects[i] is TGetItPackageInfo then
        VisiblePackages.Add(TGetItPackageInfo(lbPackages.Items.Objects[i]));
    end;

    TGetItListModel.UpdateVersionStatusForVisible(
      FPackageInfoById,
      VisiblePackages,
      InstalledIds,
      InstalledVersions,
      FListSource,
      InstalledCount,
      OutdatedCount);

    for var i := 1 to lbPackages.Items.Count - 1 do
      if lbPackages.Items.Objects[i] is TGetItPackageInfo then
        lbPackages.Items[i] := FormatPackageRow(TGetItPackageInfo(lbPackages.Items.Objects[i]));

    FLblVersionState.Caption := Format('Version check: installed %d, outdated %d',
      [InstalledCount, OutdatedCount]);
  finally
    InstalledIds.Free;
    InstalledVersions.Free;
    VisiblePackages.Free;
  end;
end;

function TfrmMain.FormatPackageRow(const Pkg: TGetItPackageInfo): string;
var
  StatusText: string;
begin
  StatusText := StatusTextForPackage(Pkg);
  if FListSource = lsRest then
    Result := PadCell(Pkg.Id, FColWidthId) + ' | ' +
              PadCell(Pkg.Version, FColWidthVersion) + ' | ' +
              PadCell(Pkg.Name, FColWidthName) + ' | ' +
              PadCell(Pkg.Vendor, FColWidthVendor) + ' | ' +
              PadCell(Pkg.TypeDescription, FColWidthType) + ' | ' +
              PadCell(CategoryTextForPackage(Pkg), FColWidthSub) + ' | ' +
              PadCell(Pkg.LibSize, FColWidthSize) + ' | ' +
              PadCell(StatusText, FColWidthStatus)
  else
    Result := PadCell(Pkg.Id, FColWidthId) + ' | ' +
              PadCell(Pkg.Version, FColWidthVersion) + ' | ' +
              PadCell(Pkg.Name, FColWidthName) + ' | ' +
              PadCell(StatusText, FColWidthStatus);
end;

procedure TfrmMain.AddOrUpdatePackageInfo(const Id, Version, Description: string);
var
  Pkg: TGetItPackageInfo;
begin
  if Id.IsEmpty then
    Exit;

  if not FPackageInfoById.TryGetValue(Id, Pkg) then
  begin
    Pkg := TGetItPackageInfo.Create;
    Pkg.Id := Id;
    if FListSource = lsRest then
      Pkg.PackageId := TGetItCore.NormalizePackageKey(Id)
    else
      Pkg.PackageId := '';
    Pkg.Name := TGetItCore.ExtractNameFromId(Id);
    FPackageInfoById.Add(Id, Pkg);
  end;

  if not Version.IsEmpty then
    Pkg.Version := Version;
  if not Description.IsEmpty then
    Pkg.Description := Description;
end;

procedure TfrmMain.actInstallCheckedExecute(Sender: TObject);
begin
  if not EnsureIdeClosedForInstall then
    Exit;

  actInstallChecked.Enabled := False;
  actRefresh.Enabled := False;
  try
    ProcessCheckedPackages(function (const GetItName: string): string
        begin
          Result := TGetItCore.BuildInstallCmd(cmbRADVersions.Text, GetItName);
        end, 'Install');
  finally
    actInstallChecked.Enabled := True;
    actRefresh.Enabled := True;
  end;
end;

procedure TfrmMain.actUninstallCheckedExecute(Sender: TObject);
begin
  actUninstallChecked.Enabled := False;
  actRefresh.Enabled := False;
  try
    ProcessCheckedPackages(function (const GetItName: string): string
        begin
          Result := TGetItCore.BuildUninstallCmd(cmbRADVersions.Text, GetItName);
        end, 'Uninstall');
  finally
    actUninstallChecked.Enabled := True;
    actRefresh.Enabled := True;
  end;
end;

procedure TfrmMain.actInstallOneExecute(Sender: TObject);
begin
  if not EnsureIdeClosedForInstall then
    Exit;

  if IsPackageIndexValid then begin
    actInstallOne.Enabled := False;
    actRefresh.Enabled := False;
    try
      frmInstallLog.Initialize;
      frmInstallLog.ProcessGetItPackage(BDSBinDir,
                 TGetItCore.BuildInstallCmd(cmbRADVersions.Text, GetPackageIdFromItemIndex(lbPackages.ItemIndex)),
                 'Install', GetPackageIdFromItemIndex(lbPackages.ItemIndex),
                 1, 1, FInstallAborted);

      frmInstallLog.NotifyFinished;
    finally
      actInstallOne.Enabled := True;
      actRefresh.Enabled := True;
    end;
  end;
end;

procedure TfrmMain.actUninstallOneExecute(Sender: TObject);
begin
  if IsPackageIndexValid then begin
    actUninstallOne.Enabled := False;
    actRefresh.Enabled := False;
    try
      frmInstallLog.Initialize;
      frmInstallLog.ProcessGetItPackage(BDSBinDir,
                         TGetItCore.BuildUninstallCmd(cmbRADVersions.Text, GetPackageIdFromItemIndex(lbPackages.ItemIndex)),
                         'Uninstall', GetPackageIdFromItemIndex(lbPackages.ItemIndex),
                         1, 1, FInstallAborted);
      frmInstallLog.NotifyFinished;
    finally
      actUninstallOne.Enabled := True;
      actRefresh.Enabled := True;
    end;
  end;
end;

procedure TfrmMain.actRefreshExecute(Sender: TObject);
begin
  RefreshViaGetItCmd;
end;

procedure TfrmMain.chkInstalledOnlyClick(Sender: TObject);
begin
  ApplyMutuallyExclusiveFilter(TCheckBox(Sender));
end;

procedure TfrmMain.cbInstalledRestClick(Sender: TObject);
begin
  ApplyMutuallyExclusiveFilter(TCheckBox(Sender));
end;

procedure TfrmMain.chkNotInstalledOnlyClick(Sender: TObject);
begin
  ApplyMutuallyExclusiveFilter(TCheckBox(Sender));
end;

procedure TfrmMain.CategoryFilterChange(Sender: TObject);
begin
  if FListSource <> lsRest then
    Exit;

  if FPackageInfoById.Count > 0 then
  begin
    RebuildVisiblePackageList;
    UpdatePackageActionsState;
  end;
end;

procedure TfrmMain.ScopeFilterChange(Sender: TObject);
begin
  if FListSource <> lsRest then
    Exit;

  if FPackageInfoById.Count = 0 then
    Exit;

  UpdateCategoryFilterItems;
  RebuildVisiblePackageList;
  UpdatePackageActionsState;
end;

procedure TfrmMain.LocalSortMenuClick(Sender: TObject);
begin
  if Sender is TMenuItem then
    FLocalSortIndex := TMenuItem(Sender).Tag;

  if FPackageInfoById.Count > 0 then
  begin
    RebuildVisiblePackageList;
    UpdatePackageActionsState;
  end;
end;

procedure TfrmMain.UpdateLocalSortMenuVisibility;
var
  IsRest: Boolean;
begin
  IsRest := FListSource = lsRest;

  FMenuSortId.Visible := True;
  FMenuSortVersion.Visible := True;
  FMenuSortName.Visible := True;
  FMenuSortVendor.Visible := IsRest;
  FMenuSortCategory.Visible := IsRest;
  FMenuSortDate.Visible := IsRest;

  if (not IsRest) and (FLocalSortIndex > 2) then
    FLocalSortIndex := 2;

  FMenuSortId.Checked := FLocalSortIndex = 0;
  FMenuSortVersion.Checked := FLocalSortIndex = 1;
  FMenuSortName.Checked := FLocalSortIndex = 2;
  FMenuSortVendor.Checked := FLocalSortIndex = 3;
  FMenuSortCategory.Checked := FLocalSortIndex = 4;
  FMenuSortDate.Checked := FLocalSortIndex = 5;
end;

procedure TfrmMain.UpdateGetItCmdSortOptionsForVersion;
var
  AllowDateSort: Boolean;
  DateIndex: Integer;
begin
  AllowDateSort := TGetItCore.SwitchFlavor(SelectedBDSVersion) = 2;

  rgrpSortBy.Items.BeginUpdate;
  try
    DateIndex := rgrpSortBy.Items.IndexOf('Date');

    if AllowDateSort then
    begin
      if DateIndex < 0 then
        rgrpSortBy.Items.Add('Date');
    end
    else if DateIndex >= 0 then
    begin
      if rgrpSortBy.ItemIndex = DateIndex then
        rgrpSortBy.ItemIndex := 0;
      rgrpSortBy.Items.Delete(DateIndex);
    end;

    rgrpSortBy.Columns := rgrpSortBy.Items.Count;
    if (rgrpSortBy.ItemIndex < 0) or (rgrpSortBy.ItemIndex >= rgrpSortBy.Items.Count) then
      rgrpSortBy.ItemIndex := 0;
  finally
    rgrpSortBy.Items.EndUpdate;
  end;
end;

function TfrmMain.GetItListArgFromRadio: string;
var
  DateIndex: Integer;
begin
  DateIndex := rgrpSortBy.Items.IndexOf('Date');

  case rgrpSortBy.ItemIndex of
    1: Result := 'vendor';
  else
    if (DateIndex >= 0) and (rgrpSortBy.ItemIndex = DateIndex) then
      Result := 'date'
    else
      Result := 'name';
  end;
end;

procedure TfrmMain.edtNameFilterChange(Sender: TObject);
var
  IsFilterActive: Boolean;
  FilterText: string;
begin
  if FPackageInfoById.Count = 0 then
    Exit;

  if FListSource <> lsRest then
    Exit;

  FilterText := Trim(lFilterRestList.Text);
  IsFilterActive := Length(FilterText) >= TEXT_FILTER_MIN_CHARS;

  if IsFilterActive then
  begin
    RebuildVisiblePackageList;
    UpdatePackageActionsState;
    FTextFilterActive := True;
  end
  else if FTextFilterActive then
  begin
    RebuildVisiblePackageList;
    UpdatePackageActionsState;
    FTextFilterActive := False;
  end;
end;

procedure TfrmMain.RefreshViaGetItCmd;
var
  CmdLineArgs: string;
  SortArg: string;
  ListArg: string;
  FilterArg: string;
  Flavor: Integer;
  StartOutputLogCount: Integer;
  HardFailureDetected: Boolean;
  LogIndex: Integer;
begin
  actRefresh.Enabled := False;
  btnRefreshRest.Enabled := False;
  try
    try
      UpdateGetItConnectionModeIndicator;
      SetOutputErrorDetected(False);
      SetOutputWarningDetected(False);
      StartOutputLogCount := FOutputLog.Count;
      AppendOutputLog('----- Refresh package list -----');
      FListSource := lsGetItCmd;
      UpdateLocalSortMenuVisibility;
      UpdateRestFilterControlsState;
      FPackageInfoById.Clear;
      ResetCategoryFilter;
      AppendOutputLog('REST-only filters disabled for GetItCmd list (Delphi/Latest/Category).');

      lbPackages.Items.Clear;
      lbPackages.ItemIndex := -1;
      ResetListParserState;

      var FilterText := Trim(edtNameFilter.Text);
      if Length(FilterText) >= TEXT_FILTER_MIN_CHARS then
        AppendOutputLog('Contains filter (local): ' + FilterText)
      else if FilterText <> '' then
        AppendOutputLog(Format('Contains filter ignored (<%d chars): %s', [TEXT_FILTER_MIN_CHARS, FilterText]));

      DosCommand.CurrentDir := BDSBinDir;
      SortArg := GetItListArgFromRadio;
      ListArg := Trim(edtNameFilter.Text);
      FilterArg := IfThen(chkInstalledOnly.Checked, 'installed', 'all');
      Flavor := TGetItCore.SwitchFlavor(SelectedBDSVersion);

      case Flavor of
        1:
          begin
            if SameText(SortArg, 'date') then
              SortArg := 'name';

            CmdLineArgs := Format('-listavailable:%s -sort:%s -filter:%s',
              [ListArg, SortArg, FilterArg]);
          end;
        2:
          if ListArg <> '' then
            CmdLineArgs := Format('--list=%s --sort=%s --filter=%s', [ListArg, SortArg, FilterArg])
          else
            CmdLineArgs := Format('--list= --sort=%s --filter=%s', [SortArg, FilterArg]);
      else
        raise ENotImplemented.Create(GETIT_VR_NOT_SUPPORTED_MSG);
      end;

      var GetItCmdPath := TPath.Combine(DosCommand.CurrentDir, 'GetItCmd.exe');
      var RsVarsPath := TPath.Combine(DosCommand.CurrentDir, 'rsvars.bat');
      if (Flavor = 1) and FileExists(RsVarsPath) then
      begin
        DosCommand.CommandLine := Format('cmd /c "call ""%s"" && ""%s"" %s"',
          [RsVarsPath, GetItCmdPath, CmdLineArgs]);
        AppendOutputLog('Using rsvars bootstrap for legacy GetItCmd.');
      end
      else
        DosCommand.CommandLine := '"' + GetItCmdPath + '" ' + CmdLineArgs;
      ExecLine := DosCommand.CommandLine;
      AppendOutputLog('Command: ' + DosCommand.CommandLine);

      Screen.Cursor := crHourGlass;
      try
        var CmdTime := TStopwatch.Create;
        CmdTime.Start;

        DosCommand.Execute;
        repeat
          Application.ProcessMessages;
        until FFinished;

        FlushCurrentPackageLine;
        CleanPackageList;

        var ParsedLines := TStringList.Create;
        try
          ParsedLines.Assign(lbPackages.Items);
          for var i := 0 to ParsedLines.Count - 1 do
            ParseAndAddPackageLine(ParsedLines[i]);
        finally
          ParsedLines.Free;
        end;

        UpdateCategoryFilterItems;
        RebuildVisiblePackageList;
        FTextFilterActive := False;

        CmdTime.Stop;
        var ElapsedMs := CmdTime.ElapsedMilliseconds;
        if ElapsedMs <= 0 then
          DownloadTime := 0
        else
          DownloadTime := ElapsedMs;
        UpdatePackageActionsState;
        AppendOutputLog(Format('Result: %d package lines.', [VisiblePackageCount]));

        HardFailureDetected := False;
        for LogIndex := StartOutputLogCount to FOutputLog.Count - 1 do
        begin
          if ContainsText(FOutputLog[LogIndex], 'cannot load data from the server') or
             ContainsText(FOutputLog[LogIndex], 'access violation') or
             ContainsText(FOutputLog[LogIndex], 'command failed') or
             StartsText('Exception:', Trim(FOutputLog[LogIndex])) then
          begin
            HardFailureDetected := True;
            Break;
          end;
        end;

        if HardFailureDetected then
          ShowMessage('GetIt list command failed, try REST.');
      finally
        Screen.Cursor := crDefault;
      end;
    except
      on E: Exception do
      begin
        SetOutputErrorDetected(True);
        AppendOutputLog('Exception: ' + E.Message);
        ShowMessage('GetIt list command failed, try REST.');
      end;
    end;
  finally
    actRefresh.Enabled := True;
    btnRefreshRest.Enabled := True;
  end;
end;

procedure TfrmMain.btnRefreshRestClick(Sender: TObject);
begin
  RefreshViaRest;
end;

function TfrmMain.ReadCatalogRepositoryStringValue(const ValueName: string): string;
var
  Reg: TRegistry;
  RootKeyPath: string;
begin
  Result := '';
  if SelectedBDSVersion.IsEmpty then
    Exit;

  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    RootKeyPath := BDS_USER_ROOT + SelectedBDSVersion + '\CatalogRepository';
    if Reg.OpenKeyReadOnly(RootKeyPath) and Reg.ValueExists(ValueName) then
    begin
      Result := Trim(Reg.ReadString(ValueName));
      if Result <> EmptyStr then
        Exit;
    end;

    Reg.RootKey := HKEY_LOCAL_MACHINE;
    RootKeyPath := BDS_MACHINE_WOW6432_ROOT + SelectedBDSVersion + '\CatalogRepository';
    if Reg.OpenKeyReadOnly(RootKeyPath) and Reg.ValueExists(ValueName) then
      Result := Trim(Reg.ReadString(ValueName));
  finally
    Reg.Free;
  end;
end;

function TfrmMain.GetDefaultServiceUrlForSelectedVersion: string;
begin
  if SelectedBDSVersion = '21.0' then
    Exit('https://getit11new.embarcadero.com');

  if SelectedBDSVersion = '22.0' then
    Exit('https://getit-104.embarcadero.com');

  if SelectedBDSVersion = '23.0' then
    Exit('https://getit12new.embarcadero.com');

  if SelectedBDSVersion = '37.0' then
    Exit('https://getit13.embarcadero.com');

  Result := '';
end;

function TfrmMain.GetServiceUrlForSelectedVersion: string;
var
  DefaultUrl: string;
begin
  Result := Trim(ReadCatalogRepositoryStringValue('ServiceUrl'));
  if Result = '' then
  begin
    DefaultUrl := GetDefaultServiceUrlForSelectedVersion;
    if DefaultUrl <> '' then
      Result := DefaultUrl;
  end;

  if AnsiStartsText('http://', Result) then
    Result := 'https://' + Result.Substring(7);
end;

function TfrmMain.GetCatalogVersionForSelectedVersion: string;
var
  ServiceUrl: string;
begin
  Result := ReadCatalogRepositoryStringValue('CatalogVersion');
  if Result <> EmptyStr then
    Exit;

  ServiceUrl := LowerCase(GetServiceUrlForSelectedVersion);
  if Pos('/v5/', ServiceUrl) > 0 then
    Exit('5');
  if Pos('/v6/', ServiceUrl) > 0 then
    Exit('6');

  if SelectedBDSVersion = '20.0' then
    Exit('5');
  if SelectedBDSVersion = '21.0' then
    Exit('5');
  if SelectedBDSVersion = '22.0' then
    Exit('5');
  if SelectedBDSVersion = '23.0' then
    Exit('5');
  if SelectedBDSVersion = '37.0' then
    Exit('6');
  Result := '6';
end;

function TfrmMain.GetProductIdForSelectedVersion: string;
begin
  Result := ReadCatalogRepositoryStringValue('ProductId');
  if Result <> EmptyStr then
    Exit;

  if SelectedBDSVersion = '20.0' then
    Exit('-1');
  if SelectedBDSVersion = '21.0' then
    Exit('2030');
  if SelectedBDSVersion = '22.0' then
    Exit('2030');
  if SelectedBDSVersion = '23.0' then
    Exit('2023');
  if SelectedBDSVersion = '37.0' then
    Exit('2024');
  Result := '2024';
end;

function TfrmMain.GetProductSkuForSelectedVersion: string;
begin
  Result := ReadCatalogRepositoryStringValue('ProductSKU');
  if Result = EmptyStr then
    Result := ReadCatalogRepositoryStringValue('ProductSku');
  if Result <> EmptyStr then
    Exit;

  if SelectedBDSVersion = '20.0' then
    Exit('-1');
  if SelectedBDSVersion = '21.0' then
    Exit('50');
  if SelectedBDSVersion = '22.0' then
    Exit('50');
  if SelectedBDSVersion = '23.0' then
    Exit('48');
  if SelectedBDSVersion = '37.0' then
    Exit('52');
  Result := '52';
end;

procedure TfrmMain.RefreshViaRest;
var
  RestRequest: TGetItRestRequest;
  ServiceUrl: string;
  RestUrl: string;
  RestTime: TStopwatch;
  ElapsedMs: Int64;
begin
  actRefresh.Enabled := False;
  btnRefreshRest.Enabled := False;
  try
    try
      SetOutputErrorDetected(False);
      SetOutputWarningDetected(False);
      UpdateGetItConnectionModeIndicator;
      AppendOutputLog('----- Refresh package list (REST) -----');
      FListSource := lsRest;
      UpdateLocalSortMenuVisibility;
      UpdateRestFilterControlsState;
      FPackageInfoById.Clear;
      ResetCategoryFilter;
      lbPackages.Items.Clear;
      lbPackages.ItemIndex := -1;

      ServiceUrl := GetServiceUrlForSelectedVersion;
      if ServiceUrl.IsEmpty then
        raise Exception.Create('ServiceUrl not resolved for selected RAD version.');

      RestUrl := TGetItRestService.CatalogInfoUrl(ServiceUrl);
      AppendOutputLog('REST URL: ' + RestUrl);
      if chkNotInstalledOnly.Checked then
        AppendOutputLog('REST filter: non installati')
      else if cbInstalledRest.Checked then
        AppendOutputLog('REST filter: installati');
      var FilterText := Trim(lFilterRestList.Text);
      if Length(FilterText) >= TEXT_FILTER_MIN_CHARS then
        AppendOutputLog('Contains filter (local): ' + FilterText)
      else if FilterText <> '' then
        AppendOutputLog(Format('Contains filter ignored (<%d chars): %s', [TEXT_FILTER_MIN_CHARS, FilterText]));

      RestRequest.ServiceUrl := ServiceUrl;
      RestRequest.CatalogVersion := GetCatalogVersionForSelectedVersion;
      RestRequest.ProductId := GetProductIdForSelectedVersion;
      RestRequest.ProductSku := GetProductSkuForSelectedVersion;
      RestRequest.IDEVersion := SelectedBDSVersion;
      RestRequest.SearchText := '';
      AppendOutputLog(Format('REST params: CatalogVersion=%s ProductId=%s ProductSku=%s',
        [RestRequest.CatalogVersion, RestRequest.ProductId, RestRequest.ProductSku]));

      RestTime := TStopwatch.StartNew;
      TGetItRestService.FetchPackages(RestRequest, FPackageInfoById,
        procedure(const Msg: string)
        begin
          AppendOutputLog(Msg);
        end);
      AppendOutputLog(Format('REST raw result: %d packages.', [FPackageInfoById.Count]));
      if FPackageInfoById.Count = 0 then
        ShowMessage('REST may be different for this RAD Studio version. Use GetItCmd for list.');

      FillMissingCategoryNamesFromRegistry;
      UpdateCategoryFilterItems;

      RebuildVisiblePackageList;
      FTextFilterActive := Length(Trim(lFilterRestList.Text)) >= TEXT_FILTER_MIN_CHARS;
      UpdatePackageActionsState;
      RestTime.Stop;
      ElapsedMs := RestTime.ElapsedMilliseconds;
      if ElapsedMs <= 0 then
        DownloadTime := 0
      else
        DownloadTime := ElapsedMs;
      ExecLine := 'REST: ' + RestUrl;
      AppendOutputLog(Format('REST result: %d package lines.', [VisiblePackageCount]));
    except
      on E: Exception do
      begin
        SetOutputErrorDetected(True);
        AppendOutputLog('REST exception: ' + E.Message);
        ShowMessage('REST may be different for this RAD Studio version. Use GetItCmd for list.');
      end;
    end;
  finally
    UpdatePackageActionsState;
    btnRefreshRest.Enabled := True;
    actRefresh.Enabled := True;
  end;
end;

procedure TfrmMain.btnToggleGetItModeClick(Sender: TObject);
begin
  AppendOutputLog('GetIt mode toggle is disabled (online-only mode).');
  UpdateGetItConnectionModeIndicator;
end;

procedure TfrmMain.DownloadSelectedViaGetItCmd(Sender: TObject);
var
  Pkg: TGetItPackageInfo;
begin
  if not TryGetSelectedPackageWithLibUrl(Pkg) then
    Exit;

  FInstallAborted := False;
  frmInstallLog.Initialize;
  frmInstallLog.ProcessGetItPackage(BDSBinDir, TGetItCore.BuildDownloadCmd(cmbRADVersions.Text, Pkg.LibUrl),
                                    'Download', Pkg.Id, 1, 1, FInstallAborted);
  frmInstallLog.NotifyFinished;
end;

procedure TfrmMain.DownloadSelectedDirectRest(Sender: TObject);
var
  Pkg: TGetItPackageInfo;
  TargetDir: string;
  FileName: string;
  TargetFile: string;
  HttpClient: THTTPClient;
  Resp: IHTTPResponse;
  Fs: TFileStream;
begin
  if not TryGetSelectedPackageWithLibUrl(Pkg) then
    Exit;

  TargetDir := '';
  if not SelectDirectory('Choose destination directory', '', TargetDir) then
    Exit;

  FileName := TPath.GetFileName(Pkg.LibUrl);
  if FileName.IsEmpty then
    FileName := Pkg.Id + '.zip';
  TargetFile := TPath.Combine(TargetDir, FileName);

  HttpClient := THTTPClient.Create;
  try
    Fs := TFileStream.Create(TargetFile, fmCreate);
    try
      Resp := HttpClient.Get(Pkg.LibUrl, Fs);
    finally
      Fs.Free;
    end;
    if Resp.StatusCode <> 200 then
      raise Exception.CreateFmt('Download failed with status %d', [Resp.StatusCode]);
  finally
    HttpClient.Free;
  end;

  AppendOutputLog('Downloaded to: ' + TargetFile);
  ShowMessage('Download complete: ' + TargetFile);
end;

procedure TfrmMain.actSaveCheckedListExecute(Sender: TObject);
var
  GetItName: string;
  CheckedList: TStringList;
begin
  CheckedList := TStringList.Create;
  try
    for var i := 1 to lbPackages.Count - 1 do
      if lbPackages.Checked[i] then begin
        GetItName := GetPackageIdFromItemIndex(i);
        CheckedList.Add(GetItName);
      end;

    FileSaveDialogSavedChecks.FileName := 'AutoGetIt for RAD Studio ' + cmbRADVersions.Text;
    if FileSaveDialogSavedChecks.Execute then
      CheckedList.SaveToFile(FileSaveDialogSavedChecks.FileName);
  finally
    CheckedList.Free;
  end;
end;

procedure TfrmMain.actLoadCheckedListExecute(Sender: TObject);
var
  GetItPos: Integer;
  CheckedList: TStringList;
begin
  CheckedList := TStringList.Create;
  try
    FileOpenDialogSavedChecks.FileName := 'AutoGetIt for RAD Studio ' + cmbRADVersions.Text;
    if FileOpenDialogSavedChecks.Execute then begin
      CheckedList.LoadFromFile(FileOpenDialogSavedChecks.FileName);

      if CountChecked > 0 then begin
        if dlgClearChecksFirst.Execute then
          case dlgClearChecksFirst.ModalResult of
            mrCancel:
              Exit;
            mrYes:
              actUncheckAll.Execute;
          end;
      end;

      for var i := 0 to CheckedList.Count - 1 do begin
        for GetItPos := 1 to lbPackages.Items.Count - 1 do
          if StartsText(CheckedList[i], lbPackages.Items[GetItPos]) then
            lbPackages.Checked[GetItPos] := True;
      end;
    end;
  finally
    CheckedList.Free;
  end;
end;

procedure TfrmMain.actCheckAllExecute(Sender: TObject);
begin
  for var i := 1 to lbPackages.Count - 1 do
    lbPackages.Checked[i] := True;
end;

procedure TfrmMain.actUncheckAllExecute(Sender: TObject);
begin
  for var i := 1 to lbPackages.Count - 1 do
    lbPackages.Checked[i] := False;
end;

function TfrmMain.BDSBinDir: string;
begin
  Result := TPath.Combine(BDSRootPath(SelectedBDSVersion), 'bin');
end;

function TfrmMain.BDSRootPath(const BDSVersion: string): string;
begin
  var Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    if Reg.OpenKey(BDS_USER_ROOT + BDSVersion, False) then
      Result := Reg.ReadString('RootDir');
  finally
    Reg.Free;
  end;
end;

procedure TfrmMain.CleanPackageList;
{ Not sure if there's a bug in DosCommand or what but the list of packages
  often contains cut-off entries that are then completed on the next line,
  like it misinterpreted a line break, so this routine goes through and
  deletes those partial entries by checking to see if the previous line
  is the start of the current line.
}
var
  LastPackage: string;
begin
  LastPackage := EmptyStr;
  for var i := lbPackages.Count - 1 downto 1 do begin
    LastPackage := lbPackages.Items[i-1];

    if (LastPackage.Length > 0) and StartsText(LastPackage, lbPackages.Items[i]) then
      lbPackages.Items.Delete(i - 1);
  end;
end;

function TfrmMain.CountChecked: Integer;
begin
  Result := 0;
  for var i := 1 to lbPackages.Count - 1 do
    if lbPackages.Checked[i] then
      Result := Result + 1;
end;

procedure TfrmMain.DosCommandNewLine(ASender: TObject; const ANewLine: string; AOutputType: TOutputType);
begin
  ParseGetItOutputLine(ANewLine, AOutputType);
end;

procedure TfrmMain.DosCommandTerminated(Sender: TObject);
begin
  FlushCurrentPackageLine;
  AppendOutputLog('Process terminated.');

  FFinished := True;
end;

procedure TfrmMain.btnOutputLogClick(Sender: TObject);
begin
  frmOutputLog.SetLogLines(FOutputLog);
  frmOutputLog.Show;
  frmOutputLog.BringToFront;
end;

procedure TfrmMain.LoadRADVersionsCombo;
begin
  cmbRADVersions.Items.Clear;

  var InstalledBDSVersions := TStringList.Create;
  var Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(BDS_USER_ROOT, False) then
      Reg.GetKeyNames(InstalledBDSVersions);
    InstalledBDSVersions.Sort;

    // find and list all versions of RAD Studio installed
    for var i := InstalledBDSVersions.Count - 1 downto 0 do begin
      var BDSVersion := InstalledBDSVersions[i];
      var ParsedVersion: Double;
      if not TGetItCore.TryParseBDSVersionValue(BDSVersion, ParsedVersion) then
        Continue;

      // make sure a root path is listed before adding this version
      if Length(BDSRootPath(BDSVersion)) > 0 then
        cmbRADVersions.Items.Add(BDSVersion + ' - ' + TGetItCore.DelphiNameFromBDSVersion(BDSVersion));
    end;

    if cmbRADVersions.Items.Count > 0 then
    begin
      cmbRADVersions.ItemIndex := 0;
      UpdateGetItCmdSortOptionsForVersion;
      actRefresh.Enabled := True;
      UpdateGetItConnectionModeIndicator;
    end
    else begin
      cmbRADVersions.Style := TComboBoxStyle.csSimple;
      cmbRADVersions.Text := '<None Found>';
      cmbRADVersions.Enabled := False;
      actRefresh.Enabled := False;
      actInstallChecked.Enabled := False;
      actUninstallChecked.Enabled := False;
      UpdateGetItConnectionModeIndicator;
    end;
  finally
    InstalledBDSVersions.Free;
    Reg.Free;
  end;
end;

procedure TfrmMain.cmbRADVersionsChange(Sender: TObject);
begin
  UpdateGetItCmdSortOptionsForVersion;
  UpdateGetItConnectionModeIndicator;
end;

function TfrmMain.ParseGetItName(const GetItLine: string): string;
begin
  var Sanitized := Trim(GetItLine);
  var Space := Pos(' ', Sanitized);
  if Space > 0 then
    Result := LeftStr(Sanitized, Space - 1)
  else
    Result := Sanitized;
end;

procedure TfrmMain.ProcessCheckedPackages(GetItArgsFunc: TGetItArgsFunction; const OperationLabel: string);
var
  GetItName: string;
  Count, Total: Integer;
begin
  FInstallAborted := False;
  Total := CountChecked;
  if Total = 0 then
    ShowMessage('There are no packages selected.')
  else begin
    Count := 0;
    frmInstallLog.Initialize;
    for var i := 1 to lbPackages.Count - 1 do begin
      if lbPackages.Checked[i] then begin
        GetItName := GetPackageIdFromItemIndex(i);

        Inc(Count);
        frmInstallLog.ProcessGetItPackage(BDSBinDir, GetItArgsFunc(GetItName),
                                          OperationLabel, GetItName,
                                          Count, Total, FInstallAborted);
      end;

      if FInstallAborted then
        Break;
    end;
    frmInstallLog.NotifyFinished;
  end;
end;

procedure TfrmMain.rgrpSortByClick(Sender: TObject);
begin
  AppendOutputLog('GetIt list parameter: ' + GetItListArgFromRadio);
end;

function TfrmMain.SelectedBDSVersion: string;
begin
  Result := TGetItCore.BDSVersionToken(cmbRADVersions.Text);
end;

procedure TfrmMain.SetDownloadTime(const Value: Integer);
var
  Seconds: Double;
begin
  Seconds := Value / 1000.0;
  StatusBar.Panels[1].Text := Format('Command run for %.1f second', [Seconds]);
  StatusBar.Update;
end;

procedure TfrmMain.SetExecLine(const Value: string);
begin
  StatusBar.Panels[2].Text := Value;
  StatusBar.Update;
end;

procedure TfrmMain.SetPackageCount(const Value: Integer);
var
  TotalCount: Integer;
begin
  TotalCount := FPackageInfoById.Count;
  if TotalCount < Value then
    TotalCount := Value;

  StatusBar.Panels[0].Text := Format('Listed %d of %d packages', [Value, TotalCount]);
  StatusBar.Update;
end;

end.


























