unit uGetItListModel;

interface

uses
  System.Generics.Collections,
  uGetItTypes;

type
  TGetItListModel = record
  public
    class function IsDelphiPackage(const Pkg: TGetItPackageInfo): Boolean; static;
    class function BuildPackageGroupKey(const Pkg: TGetItPackageInfo): string; static;
    class function ComparePackageDate(const Left, Right: TGetItPackageInfo): Integer; static;
    class function ShouldIncludeByInstalledFilter(const Pkg: TGetItPackageInfo;
      const InstalledIds: TDictionary<string, Byte>; const InstalledOnly, NotInstalledOnly: Boolean): Boolean; static;
    class procedure UpdateVersionStatusForVisible(
      const AllPackages: TObjectDictionary<string, TGetItPackageInfo>;
      const VisiblePackages: TList<TGetItPackageInfo>;
      const InstalledIds: TDictionary<string, Byte>;
      const InstalledVersions: TDictionary<string, string>;
      const ListSource: TListSource;
      out InstalledCount, OutdatedCount: Integer); static;
  end;

implementation

uses
  System.SysUtils, System.DateUtils, uGetItCore;

class function TGetItListModel.IsDelphiPackage(const Pkg: TGetItPackageInfo): Boolean;
var
  CodeValue: Integer;
  CodeName: string;
  IdText: string;
  NameText: string;
begin
  if TryStrToInt(Trim(Pkg.LibCode), CodeValue) then
  begin
    if CodeValue = 2 then
      Exit(False);
    if (CodeValue = 1) or (CodeValue = 5) then
      Exit(True);
  end;

  CodeName := Trim(LowerCase(Pkg.LibCodeName));
  if CodeName <> '' then
  begin
    if Pos('cplusplusbuilder', CodeName) > 0 then
      Exit(False);
    if (Pos('delphi', CodeName) > 0) or (Pos('allpersonalities', CodeName) > 0) then
      Exit(True);
  end;

  IdText := LowerCase(Pkg.Id + ' ' + Pkg.PackageId);
  NameText := LowerCase(Pkg.Name);
  if (Pos('-cb-', IdText) > 0) or IdText.EndsWith('-cb') or
     (Pos('cb-', IdText) > 0) or (Pos('(c++)', NameText) > 0) then
    Exit(False);

  Result := True;
end;

class function TGetItListModel.BuildPackageGroupKey(const Pkg: TGetItPackageInfo): string;
var
  BaseKey: string;
begin
  BaseKey := TGetItCore.NormalizePackageKey(Pkg.Id);
  if BaseKey = '' then
    BaseKey := LowerCase(Pkg.Id);

  Result := BaseKey + '|' + Trim(LowerCase(Pkg.Vendor));
end;

class function TGetItListModel.ComparePackageDate(const Left, Right: TGetItPackageInfo): Integer;
var
  LeftDate, RightDate: TDateTime;
  LeftDateStr, RightDateStr: string;
begin
  LeftDateStr := Trim(Left.VersionTimestamp);
  if LeftDateStr = '' then
    LeftDateStr := Trim(Left.Modified);
  RightDateStr := Trim(Right.VersionTimestamp);
  if RightDateStr = '' then
    RightDateStr := Trim(Right.Modified);

  if TryISO8601ToDate(LeftDateStr, LeftDate) and TryISO8601ToDate(RightDateStr, RightDate) then
  begin
    if LeftDate > RightDate then
      Exit(-1);
    if LeftDate < RightDate then
      Exit(1);
    Exit(0);
  end;

  if TryStrToDateTime(LeftDateStr, LeftDate) and TryStrToDateTime(RightDateStr, RightDate) then
  begin
    if LeftDate > RightDate then
      Exit(-1);
    if LeftDate < RightDate then
      Exit(1);
    Exit(0);
  end;

  Result := TGetItCore.CompareVersionText(Right.Version, Left.Version);
end;

class function TGetItListModel.ShouldIncludeByInstalledFilter(const Pkg: TGetItPackageInfo;
  const InstalledIds: TDictionary<string, Byte>; const InstalledOnly, NotInstalledOnly: Boolean): Boolean;
var
  CompareKey: string;
  IsInstalled: Boolean;
begin
  if (not InstalledOnly) and (not NotInstalledOnly) then
    Exit(True);

  CompareKey := Trim(LowerCase(Pkg.Id));
  IsInstalled := (CompareKey <> '') and InstalledIds.ContainsKey(CompareKey);

  if InstalledOnly then
    Exit(IsInstalled);
  if NotInstalledOnly then
    Exit(not IsInstalled);
  Result := True;
end;

class procedure TGetItListModel.UpdateVersionStatusForVisible(
  const AllPackages: TObjectDictionary<string, TGetItPackageInfo>;
  const VisiblePackages: TList<TGetItPackageInfo>;
  const InstalledIds: TDictionary<string, Byte>;
  const InstalledVersions: TDictionary<string, string>;
  const ListSource: TListSource;
  out InstalledCount, OutdatedCount: Integer);
var
  LatestRepo: TDictionary<string, string>;
  IdIndex: TDictionary<string, TGetItPackageInfo>;
  InstalledByGroup: TDictionary<string, string>;
  Key, CurLatest: string;
  InstalledLookupKey: string;
  InstalledGroupKey: string;
  InstalledPkg: TGetItPackageInfo;
  IsInstalledById: Boolean;
begin
  LatestRepo := TDictionary<string, string>.Create;
  IdIndex := TDictionary<string, TGetItPackageInfo>.Create;
  InstalledByGroup := TDictionary<string, string>.Create;
  try
    for var Pair in AllPackages do
    begin
      IdIndex.AddOrSetValue(Trim(LowerCase(Pair.Value.Id)), Pair.Value);

      if (ListSource = lsRest) and (not IsDelphiPackage(Pair.Value)) then
        Continue;

      Key := BuildPackageGroupKey(Pair.Value);
      if Key = '' then
        Continue;

      if not LatestRepo.TryGetValue(Key, CurLatest) then
        LatestRepo.Add(Key, Pair.Value.Version)
      else if TGetItCore.CompareVersionText(CurLatest, Pair.Value.Version) < 0 then
        LatestRepo[Key] := Pair.Value.Version;
    end;

    for var InstalledPair in InstalledVersions do
    begin
      InstalledLookupKey := Trim(LowerCase(InstalledPair.Key));
      if InstalledLookupKey = '' then
        Continue;

      if IdIndex.TryGetValue(InstalledLookupKey, InstalledPkg) then
      begin
        InstalledGroupKey := BuildPackageGroupKey(InstalledPkg);
        if InstalledGroupKey <> '' then
        begin
          if not InstalledByGroup.TryGetValue(InstalledGroupKey, CurLatest) then
            InstalledByGroup.Add(InstalledGroupKey, InstalledPair.Value)
          else if TGetItCore.CompareVersionText(CurLatest, InstalledPair.Value) < 0 then
            InstalledByGroup[InstalledGroupKey] := InstalledPair.Value;
        end;
      end;
    end;

    OutdatedCount := 0;
    InstalledCount := 0;
    for var Pkg in VisiblePackages do
    begin
      Key := BuildPackageGroupKey(Pkg);

      if LatestRepo.TryGetValue(Key, CurLatest) then
        Pkg.LatestVersion := CurLatest
      else
        Pkg.LatestVersion := Pkg.Version;

      InstalledLookupKey := Trim(LowerCase(Pkg.Id));
      IsInstalledById := (InstalledLookupKey <> '') and InstalledIds.ContainsKey(InstalledLookupKey);

      if InstalledByGroup.TryGetValue(Key, Pkg.InstalledVersion) or
         InstalledVersions.TryGetValue(InstalledLookupKey, Pkg.InstalledVersion) then
      begin
        Inc(InstalledCount);
        if TGetItCore.CompareVersionText(Pkg.InstalledVersion, Pkg.LatestVersion) < 0 then
        begin
          Pkg.VersionStatus := 'Outdated';
          Inc(OutdatedCount);
        end
        else
          Pkg.VersionStatus := 'Installed';
      end
      else
      begin
        if IsInstalledById then
        begin
          Inc(InstalledCount);
          Pkg.InstalledVersion := '';
          Pkg.VersionStatus := 'Installed';
        end
        else
        begin
          Pkg.InstalledVersion := '';
          Pkg.VersionStatus := 'NotInstalled';
        end;
      end;
    end;
  finally
    InstalledByGroup.Free;
    IdIndex.Free;
    LatestRepo.Free;
  end;
end;

end.
