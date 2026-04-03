unit ufrmOutputLog;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Dialogs;

type
  TfrmOutputLog = class(TForm)
    mmoOutput: TMemo;
    pnlBottom: TPanel;
    btnExport: TButton;
    btnClear: TButton;
    btnClose: TButton;
    dlgSaveLog: TSaveDialog;
    procedure btnExportClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    FSharedLog: TStrings;
  public
    procedure SetLogLines(const Lines: TStrings);
    procedure AppendLogLine(const Line: string);
  end;

var
  frmOutputLog: TfrmOutputLog;

implementation

{$R *.dfm}

procedure TfrmOutputLog.AppendLogLine(const Line: string);
begin
  if FSharedLog <> nil then
    FSharedLog.Add(Line);
  mmoOutput.Lines.Add(Line);
  mmoOutput.SelStart := Length(mmoOutput.Text);
end;

procedure TfrmOutputLog.btnClearClick(Sender: TObject);
begin
  if FSharedLog <> nil then
    FSharedLog.Clear;
  mmoOutput.Clear;
end;

procedure TfrmOutputLog.btnCloseClick(Sender: TObject);
begin
  Hide;
end;

procedure TfrmOutputLog.btnExportClick(Sender: TObject);
begin
  if dlgSaveLog.Execute then
    mmoOutput.Lines.SaveToFile(dlgSaveLog.FileName);
end;

procedure TfrmOutputLog.SetLogLines(const Lines: TStrings);
begin
  FSharedLog := Lines;
  mmoOutput.Lines.Assign(Lines);
  mmoOutput.SelStart := Length(mmoOutput.Text);
end;

end.
