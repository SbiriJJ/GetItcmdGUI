program GetItcmdGUI;





uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  ufrmMain in 'ufrmMain.pas' {frmAutoGetItMain},
  ufrmInstallLog in 'ufrmInstallLog.pas' {frmInstallLog},
  ufrmOutputLog in 'ufrmOutputLog.pas' {frmOutputLog},
  uGetItCore in 'uGetItCore.pas',
  uGetItListModel in 'uGetItListModel.pas',
  uGetItRestService in 'uGetItRestService.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'GetIt Manager';
  TStyleManager.TrySetStyle('Windows11 Polar Dark');
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmInstallLog, frmInstallLog);
  Application.CreateForm(TfrmOutputLog, frmOutputLog);
  Application.Run;
end.
