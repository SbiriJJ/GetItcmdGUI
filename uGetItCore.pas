unit uGetItCore;

interface

uses
  System.Classes, System.SysUtils, System.StrUtils;

const
  GETIT_VR_NOT_SUPPORTED_MSG = 'GetItCmd not supported for this version of Delphi';

type
  TGetItCore = record
  private
    class function ContainsAnyText(const Source: string; const Tokens: array of string): Boolean; static;
    class function IsBenignKnownWarning(const Line: string): Boolean; static;
  public
    class function BDSVersionToken(const DelphiVersionStr: string): string; static;
    class function TryParseBDSVersionValue(const DelphiVersionStr: string; out BDSVersion: Double): Boolean; static;
    class function DelphiNameFromBDSVersion(const BDSVersion: string): string; static;
    class function SwitchFlavor(const DelphiVersionStr: string): Integer; static;
    class function BuildInstallCmd(const DelphiVersionStr, GetItPackageName: string): string; static;
    class function BuildUninstallCmd(const DelphiVersionStr, GetItPackageName: string): string; static;
    class function BuildDownloadCmd(const DelphiVersionStr, FileUrl: string): string; static;
    class function ExtractNameFromId(const AId: string): string; static;
    class function NormalizePackageKey(const AId: string): string; static;
    class function CompareVersionText(const LeftV, RightV: string): Integer; static;
    class function IsLikelyErrorText(const Line: string): Boolean; static;
    class function IsLikelyWarningText(const Line: string): Boolean; static;
  end;

implementation

class function TGetItCore.ContainsAnyText(const Source: string; const Tokens: array of string): Boolean;
begin
  for var i := Low(Tokens) to High(Tokens) do
    if ContainsText(Source, Tokens[i]) then
      Exit(True);
  Result := False;
end;

class function TGetItCore.IsBenignKnownWarning(const Line: string): Boolean;
begin
  Result := ContainsText(Line, '[einouterror] i/o error 32') or
            ContainsText(Line, 'i/o error 32');
end;

class function TGetItCore.BDSVersionToken(const DelphiVersionStr: string): string;
var
  SpacePos: Integer;
begin
  Result := Trim(DelphiVersionStr);
  SpacePos := Pos(' ', Result);
  if SpacePos > 0 then
    Result := Copy(Result, 1, SpacePos - 1);
end;

class function TGetItCore.TryParseBDSVersionValue(const DelphiVersionStr: string; out BDSVersion: Double): Boolean;
begin
  Result := TryStrToFloat(BDSVersionToken(DelphiVersionStr), BDSVersion, TFormatSettings.Invariant);
end;

class function TGetItCore.DelphiNameFromBDSVersion(const BDSVersion: string): string;
begin
  if BDSVersion = '19.0' then
    Exit('Delphi 10.2 Tokyo');
  if BDSVersion = '20.0' then
    Exit('Delphi 10.3 Rio');
  if BDSVersion = '21.0' then
    Exit('Delphi 10.4 Sydney');
  if BDSVersion = '22.0' then
    Exit('Delphi 11 Alexandria');
  if BDSVersion = '23.0' then
    Exit('Delphi 12 Athens');
  if BDSVersion = '37.0' then
    Exit('Delphi 13 Florence');

  Result := 'RAD Studio';
end;

class function TGetItCore.SwitchFlavor(const DelphiVersionStr: string): Integer;
var
  BDSVersion: Double;
begin
  if not TryParseBDSVersionValue(DelphiVersionStr, BDSVersion) then
    Exit(-1);

  if BDSVersion <= 20.0 then
    Result := 1
  else if BDSVersion >= 21.0 then
    Result := 2
  else
    Result := -1;
end;

class function TGetItCore.BuildInstallCmd(const DelphiVersionStr, GetItPackageName: string): string;
begin
  case SwitchFlavor(DelphiVersionStr) of
    1: Result := Format('-accept_eulas -i"%s"', [GetItPackageName]);
    2: Result := Format('-ae -i="%s"', [GetItPackageName]);
  else
    raise ENotImplemented.Create(GETIT_VR_NOT_SUPPORTED_MSG);
  end;
end;

class function TGetItCore.BuildUninstallCmd(const DelphiVersionStr, GetItPackageName: string): string;
begin
  case SwitchFlavor(DelphiVersionStr) of
    1: Result := Format('-u"%s"', [GetItPackageName]);
    2: Result := Format('-u="%s"', [GetItPackageName]);
  else
    raise ENotImplemented.Create(GETIT_VR_NOT_SUPPORTED_MSG);
  end;
end;

class function TGetItCore.BuildDownloadCmd(const DelphiVersionStr, FileUrl: string): string;
begin
  case SwitchFlavor(DelphiVersionStr) of
    1: Result := Format('-d"%s"', [FileUrl]);
    2: Result := Format('-d="%s"', [FileUrl]);
  else
    raise ENotImplemented.Create(GETIT_VR_NOT_SUPPORTED_MSG);
  end;
end;

class function TGetItCore.ExtractNameFromId(const AId: string): string;
var
  DashPos: Integer;
begin
  Result := AId;
  DashPos := Pos('-', AId);
  if DashPos > 1 then
    Result := Copy(AId, 1, DashPos - 1);
end;

class function TGetItCore.NormalizePackageKey(const AId: string): string;
var
  SourceId: string;
  LastDash: Integer;
  LastToken: string;
  OnlyVersionChars: Boolean;
begin
  SourceId := Trim(LowerCase(AId));
  if SourceId = '' then
    Exit('');

  LastDash := LastDelimiter('-', SourceId);
  if LastDash <= 0 then
    Exit(SourceId);

  LastToken := Copy(SourceId, LastDash + 1, MaxInt);
  OnlyVersionChars := LastToken <> '';
  for var i := 1 to Length(LastToken) do
    if not CharInSet(LastToken[i], ['0'..'9', '.']) then
    begin
      OnlyVersionChars := False;
      Break;
    end;

  if OnlyVersionChars then
    Result := Copy(SourceId, 1, LastDash - 1)
  else
    Result := SourceId;
end;

class function TGetItCore.CompareVersionText(const LeftV, RightV: string): Integer;
var
  LeftParts, RightParts: TStringList;
  MaxLen: Integer;
  LeftNum, RightNum: Integer;
  HasLeftNum, HasRightNum: Boolean;
  L, R: string;
  procedure FillParts(const Src: string; Parts: TStringList);
  var
    S: string;
  begin
    S := StringReplace(Src, '-', '.', [rfReplaceAll]);
    S := StringReplace(S, '_', '.', [rfReplaceAll]);
    Parts.Delimiter := '.';
    Parts.StrictDelimiter := True;
    Parts.DelimitedText := S;
  end;
begin
  if SameText(Trim(LeftV), Trim(RightV)) then
    Exit(0);

  LeftParts := TStringList.Create;
  RightParts := TStringList.Create;
  try
    FillParts(LeftV, LeftParts);
    FillParts(RightV, RightParts);

    MaxLen := LeftParts.Count;
    if RightParts.Count > MaxLen then
      MaxLen := RightParts.Count;

    for var i := 0 to MaxLen - 1 do
    begin
      if i < LeftParts.Count then
        L := LeftParts[i]
      else
        L := '0';
      if i < RightParts.Count then
        R := RightParts[i]
      else
        R := '0';

      HasLeftNum := TryStrToInt(L, LeftNum);
      HasRightNum := TryStrToInt(R, RightNum);
      if HasLeftNum and HasRightNum then
      begin
        if LeftNum < RightNum then Exit(-1);
        if LeftNum > RightNum then Exit(1);
      end
      else
      begin
        Result := CompareText(L, R);
        if Result <> 0 then
          Exit(Result);
      end;
    end;
    Result := 0;
  finally
    LeftParts.Free;
    RightParts.Free;
  end;
end;

class function TGetItCore.IsLikelyErrorText(const Line: string): Boolean;
const
  ERROR_PATTERNS: array[0..13] of string = (
    'error:',
    'command failed',
    'failed to get info',
    'failed to install',
    'failed to uninstall',
    'fatal',
    'exception',
    'not found',
    'invalid option',
    'msbuild : error',
    ' error msb',
    ': error e',
    ': error f',
    'error when '
  );
begin
  if Trim(Line).IsEmpty then
    Exit(False);

  if IsBenignKnownWarning(Line) then
    Exit(False);

  Result := ContainsAnyText(Line, ERROR_PATTERNS);
end;

class function TGetItCore.IsLikelyWarningText(const Line: string): Boolean;
const
  WARNING_PATTERNS: array[0..4] of string = (
    'warning:',
    '[warning]',
    '[einouterror]',
    'i/o error',
    'retrying'
  );
begin
  if Trim(Line).IsEmpty then
    Exit(False);

  Result := ContainsAnyText(Line, WARNING_PATTERNS) and
            (not IsLikelyErrorText(Line));
end;

end.

