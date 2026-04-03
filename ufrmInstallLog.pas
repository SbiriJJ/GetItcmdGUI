unit ufrmInstallLog;

interface

uses
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.ComCtrls, Vcl.StdCtrls, DosCommand,
  Vcl.Buttons, Vcl.ExtCtrls, Vcl.Dialogs;

type
  TfrmInstallLog = class(TForm)
    lbInstallLog: TListBox;
    DosCmdGetItInstall: TDosCommand;
    pnlLogBottom: TPanel;
    btnCancel: TBitBtn;
    lblCount: TLabel;
    pbInstalls: TProgressBar;
    btnClose: TBitBtn;
    btnSave: TBitBtn;
    dlgSaveLog: TSaveDialog;
    procedure DosCmdGetItInstallNewLine(ASender: TObject;
      const ANewLine: string; AOutputType: TOutputType);
    procedure DosCmdGetItInstallTerminated(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    FAbort: Boolean;
    FFinished: Boolean;
    FCurrentOperation: string;
    FCurrentTarget: string;
    FRunHasErrors: Boolean;
    FRunHasWarnings: Boolean;
    FRunSawSuccessText: Boolean;
    FRunErrorCount: Integer;
    FRunWarningCount: Integer;
    FRunFirstErrorLine: string;
    FRunFirstWarningLine: string;
    FSummaryLines: TStringList;
    FTotalCommands: Integer;
    FTotalSucceeded: Integer;
    FTotalUnknown: Integer;
    FTotalFailed: Integer;
    FTotalAborted: Integer;
    FTotalWithWarnings: Integer;
    procedure AddLog(const LogMsg: string);
    procedure ResetRunState;
    function IsLikelySuccessText(const Line: string): Boolean;
    function BuildRunSummaryLine: string;
  public
    destructor Destroy; override;
  public
    procedure Initialize;
    procedure NotifyFinished;
    procedure ProcessGetItPackage(const StartDir, GetItCmdArgs: string;
                                  const OperationLabel, TargetLabel: string;
                                  const Count, Total: Integer;
                                  var Aborted: Boolean);
  end;

var
  frmInstallLog: TfrmInstallLog;

implementation

{$R *.dfm}

uses
  System.SysUtils, System.IOUtils, System.Diagnostics, System.StrUtils, uGetItCore;

{ TfrmInstallLog }

procedure TfrmInstallLog.AddLog(const LogMsg: string);
begin
  lbInstallLog.Items.Add(LogMsg);
  lbInstallLog.ItemIndex := lbInstallLog.Items.Count - 1;
  lbInstallLog.Update;
end;

destructor TfrmInstallLog.Destroy;
begin
  FSummaryLines.Free;
  inherited;
end;

procedure TfrmInstallLog.btnCancelClick(Sender: TObject);
begin
  FAbort := True;
  DosCmdGetItInstall.Stop;
end;

procedure TfrmInstallLog.btnCloseClick(Sender: TObject);
begin
  Hide;
end;

procedure TfrmInstallLog.btnSaveClick(Sender: TObject);
begin
  if dlgSaveLog.Execute then
    lbInstallLog.Items.SaveToFile(dlgSaveLog.FileName);
end;

procedure TfrmInstallLog.Initialize;
begin
  lbInstallLog.Items.Clear;
  FreeAndNil(FSummaryLines);
  FSummaryLines := TStringList.Create;

  FTotalCommands := 0;
  FTotalSucceeded := 0;
  FTotalUnknown := 0;
  FTotalFailed := 0;
  FTotalAborted := 0;
  FTotalWithWarnings := 0;

  btnCancel.BringToFront;
  Show;
end;

procedure TfrmInstallLog.ResetRunState;
begin
  FRunHasErrors := False;
  FRunHasWarnings := False;
  FRunSawSuccessText := False;
  FRunErrorCount := 0;
  FRunWarningCount := 0;
  FRunFirstErrorLine := '';
  FRunFirstWarningLine := '';
end;

function TfrmInstallLog.IsLikelySuccessText(const Line: string): Boolean;
begin
  Result := ContainsText(Line, 'completed with success') or
            ContainsText(Line, 'installed successfully') or
            ContainsText(Line, 'operation completed successfully') or
            ContainsText(Line, 'command finished');
end;

function TfrmInstallLog.BuildRunSummaryLine: string;
var
  ResultState: string;
  InstalledState: string;
  AbortedText: string;
begin
  if FAbort then
    ResultState := 'ABORTED'
  else if FRunHasErrors then
    ResultState := 'ERROR'
  else if FRunSawSuccessText then
    ResultState := 'OK'
  else
    ResultState := 'UNKNOWN';

  if SameText(FCurrentOperation, 'Install') then
  begin
    if FAbort or FRunHasErrors then
      InstalledState := 'NO'
    else if FRunSawSuccessText then
      InstalledState := 'YES'
    else
      InstalledState := 'UNKNOWN';
  end
  else
    InstalledState := '-';

  if FAbort then
    AbortedText := 'YES'
  else
    AbortedText := 'NO';

  Result := Format('[%s] %s | result=%s | installed=%s | warnings=%d | errors=%d | aborted=%s',
                   [FCurrentOperation, FCurrentTarget, ResultState, InstalledState,
                    FRunWarningCount, FRunErrorCount, AbortedText]);
end;

procedure TfrmInstallLog.DosCmdGetItInstallNewLine(ASender: TObject;
  const ANewLine: string; AOutputType: TOutputType);
begin
  if AOutputType <> otEntireLine then
    Exit;

  AddLog(ANewLine);
  if TGetItCore.IsLikelyErrorText(ANewLine) then
  begin
    FRunHasErrors := True;
    Inc(FRunErrorCount);
    if FRunFirstErrorLine = '' then
      FRunFirstErrorLine := Trim(ANewLine);
  end
  else if TGetItCore.IsLikelyWarningText(ANewLine) then
  begin
    FRunHasWarnings := True;
    Inc(FRunWarningCount);
    if FRunFirstWarningLine = '' then
      FRunFirstWarningLine := Trim(ANewLine);
  end;

  if IsLikelySuccessText(ANewLine) then
    FRunSawSuccessText := True;
end;

procedure TfrmInstallLog.DosCmdGetItInstallTerminated(Sender: TObject);
begin
  FFinished := True;
end;

procedure TfrmInstallLog.ProcessGetItPackage(const StartDir, GetItCmdArgs: string;
                                             const OperationLabel, TargetLabel: string;
                                             const Count, Total: Integer;
                                             var Aborted: Boolean);
begin
  lblCount.Caption := Format('%d of %d packages', [Count, Total]);
  lblCount.Update;

  pbInstalls.Max := Total;
  pbInstalls.Position := Count;
  pbInstalls.Update;

  DosCmdGetItInstall.CurrentDir := StartDir;

  var RsVarsPath := TPath.Combine(StartDir, 'rsvars.bat');
  var GetItCmdPath := TPath.Combine(StartDir, 'GetItCmd.exe');

  // Set up selected Delphi environment, then run the matching GetItCmd for that version.
  DosCmdGetItInstall.CommandLine := Format('cmd /c call "%s" && "%s" %s',
                                           [RsVarsPath, GetItCmdPath, GetItCmdArgs]);

  FCurrentOperation := OperationLabel;
  FCurrentTarget := TargetLabel;
  if FCurrentOperation = '' then
    FCurrentOperation := 'Run';
  if FCurrentTarget = '' then
    FCurrentTarget := '(n/a)';

  AddLog(Format('Running [%s] %s', [FCurrentOperation, FCurrentTarget]));
  AddLog('Command Line: ' + DosCmdGetItInstall.CommandLine);

  ResetRunState;
  FAbort := False;
  FFinished := False;
  btnCancel.Enabled := True;
  Screen.Cursor := crHourGlass;
  try
    DosCmdGetItInstall.Execute;
    repeat
      Application.ProcessMessages;
    until FFinished or FAbort;

    if FRunHasWarnings then
    begin
      AddLog('Detected warnings in command output.');
      if FRunFirstWarningLine <> '' then
        AddLog('First warning: ' + FRunFirstWarningLine);
    end;
    if FRunHasErrors then
    begin
      AddLog('Detected textual errors in command output.');
      if FRunFirstErrorLine <> '' then
        AddLog('First error: ' + FRunFirstErrorLine);
    end;

    FSummaryLines.Add(BuildRunSummaryLine);

    Inc(FTotalCommands);
    if FAbort then
      Inc(FTotalAborted)
    else if FRunHasErrors then
      Inc(FTotalFailed)
    else if FRunSawSuccessText then
      Inc(FTotalSucceeded)
    else
      Inc(FTotalUnknown);

    if FRunHasWarnings then
      Inc(FTotalWithWarnings);

    AddLog('========================');
  finally
    Screen.Cursor := crDefault;
  end;

  Aborted := FAbort;
  if FAbort then
    AddLog('Aborted!');
end;

procedure TfrmInstallLog.NotifyFinished;
begin
  if FSummaryLines.Count > 0 then
  begin
    AddLog('===== Package Summary =====');
    for var i := 0 to FSummaryLines.Count - 1 do
      AddLog(FSummaryLines[i]);
    AddLog(Format('Totals: commands=%d, ok=%d, unknown=%d, errors=%d, aborted=%d, with warnings=%d',
      [FTotalCommands, FTotalSucceeded, FTotalUnknown, FTotalFailed, FTotalAborted, FTotalWithWarnings]));
  end;

  AddLog('Finished');
  btnClose.BringToFront;
end;

end.
