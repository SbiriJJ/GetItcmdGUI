unit uGetItRestService;

interface

uses
  System.Generics.Collections, System.JSON,
  uGetItTypes;

type
  TGetItRestRequest = record
    ServiceUrl: string;
    CatalogVersion: string;
    ProductId: string;
    ProductSku: string;
    IDEVersion: string;
    SearchText: string;
  end;

  TGetItRestLogProc = reference to procedure(const Msg: string);

  TGetItRestService = record
  public
    class function CatalogInfoUrl(const ServiceUrl: string): string; static;
    class procedure FetchPackages(const Request: TGetItRestRequest;
      const Target: TObjectDictionary<string, TGetItPackageInfo>;
      const OnLog: TGetItRestLogProc); static;
  private
    class function BuildRestBody(const Request: TGetItRestRequest; const StartIndex, EndIndex: Integer): string; static;
    class function JsonValueToString(const Obj: TJSONObject; const Name: string): string; static;
    class procedure ReadCategories(const Obj: TJSONObject; out CategoryIds, CategoryNames: string); static;
    class function TryGetArrayFromPayload(const JsonRoot: TJSONValue; out Arr: TJSONArray): Boolean; static;
    class function ResponsePreview(const Content: string; const MaxLen: Integer = 240): string; static;
  end;

implementation

uses
  System.SysUtils, System.Classes, System.Net.HttpClient, System.Net.URLClient, System.NetEncoding,
  uGetItCore;

class function TGetItRestService.CatalogInfoUrl(const ServiceUrl: string): string;
var
  BaseUrl: string;
begin
  BaseUrl := Trim(ServiceUrl);
  if BaseUrl.EndsWith('/') then
    Result := BaseUrl + 'catalog/info'
  else
    Result := BaseUrl + '/catalog/info';
end;

class function TGetItRestService.BuildRestBody(const Request: TGetItRestRequest; const StartIndex, EndIndex: Integer): string;
var
  VersionText: string;
  FilterByLicenseText: string;
  PersonalitiesText: string;
begin
  VersionText := Request.IDEVersion;
  if VersionText = '' then
    VersionText := '0';

  FilterByLicenseText := '0';
  PersonalitiesText := '1';
  if SameText(VersionText, '20.0') then
  begin
    FilterByLicenseText := '1';
    PersonalitiesText := '0';
  end;

  Result := Format(
    'Start=%d&End=%d&Categories=-1&CalculateSize=0&FilterByLicense=%s&Order=%d' +
    '&Version=%s&Identity=RADSTUDIO&Personalities=%s&Platforms=0&Frameworks=0' +
    '&ProductSKU=%s&IsTrial=0&CatalogVersion=%s&ClientVersion=7.0&LanguageCode=EN&ProductId=%s' +
    '&ProductIds=%s&ProductSKUs=%s&IsTrials=0&Search=%s',
    [StartIndex, EndIndex,
     TNetEncoding.URL.Encode(FilterByLicenseText),
     0,
     TNetEncoding.URL.Encode(VersionText),
     TNetEncoding.URL.Encode(PersonalitiesText),
     TNetEncoding.URL.Encode(Request.ProductSku),
     TNetEncoding.URL.Encode(Request.CatalogVersion),
     TNetEncoding.URL.Encode(Request.ProductId),
     TNetEncoding.URL.Encode(Request.ProductId),
     TNetEncoding.URL.Encode(Request.ProductSku),
     TNetEncoding.URL.Encode(Request.SearchText)]);
end;
class function TGetItRestService.JsonValueToString(const Obj: TJSONObject; const Name: string): string;
begin
  Result := '';
  Obj.TryGetValue<string>(Name, Result);
end;

class procedure TGetItRestService.ReadCategories(const Obj: TJSONObject; out CategoryIds, CategoryNames: string);
var
  CategoriesValue: TJSONValue;
  CategoriesArray: TJSONArray;
  CategoryObj: TJSONObject;
  CategoryId: string;
  CategoryName: string;
begin
  CategoryIds := '';
  CategoryNames := '';

  CategoriesValue := Obj.GetValue('Categories');
  if not (CategoriesValue is TJSONArray) then
    Exit;

  CategoriesArray := TJSONArray(CategoriesValue);
  for var i := 0 to CategoriesArray.Count - 1 do
  begin
    if not (CategoriesArray.Items[i] is TJSONObject) then
      Continue;

    CategoryObj := CategoriesArray.Items[i] as TJSONObject;
    CategoryId := JsonValueToString(CategoryObj, 'Id');
    CategoryName := JsonValueToString(CategoryObj, 'Name');

    if CategoryId <> '' then
    begin
      if CategoryIds <> '' then
        CategoryIds := CategoryIds + ', ';
      CategoryIds := CategoryIds + CategoryId;
    end;

    if CategoryName <> '' then
    begin
      if CategoryNames <> '' then
        CategoryNames := CategoryNames + ', ';
      CategoryNames := CategoryNames + CategoryName;
    end;
  end;
end;

class function TGetItRestService.ResponsePreview(const Content: string; const MaxLen: Integer): string;
var
  Normalized: string;
begin
  Normalized := Content.Replace(#13, ' ').Replace(#10, ' ').Trim;
  if Length(Normalized) > MaxLen then
    Result := Copy(Normalized, 1, MaxLen) + '...'
  else
    Result := Normalized;
end;

class function TGetItRestService.TryGetArrayFromPayload(const JsonRoot: TJSONValue; out Arr: TJSONArray): Boolean;
const
  TopLevelArrayKeys: array[0..11] of string = (
    'Items', 'items', 'Data', 'data', 'Result', 'result',
    'Value', 'value', 'CatalogItems', 'catalogItems', 'Packages', 'packages');
  NestedObjectKeys: array[0..5] of string = ('Data', 'data', 'Result', 'result', 'Value', 'value');
  NestedArrayKeys: array[0..3] of string = ('Items', 'items', 'Packages', 'packages');
var
  Obj: TJSONObject;
  NestedObj: TJSONObject;
  V: TJSONValue;
begin
  Arr := nil;

  if JsonRoot is TJSONArray then
  begin
    Arr := TJSONArray(JsonRoot);
    Exit(True);
  end;

  if not (JsonRoot is TJSONObject) then
    Exit(False);

  Obj := TJSONObject(JsonRoot);

  for var Key in TopLevelArrayKeys do
  begin
    V := Obj.GetValue(Key);
    if V is TJSONArray then
    begin
      Arr := TJSONArray(V);
      Exit(True);
    end;
  end;

  for var ContainerKey in NestedObjectKeys do
  begin
    V := Obj.GetValue(ContainerKey);
    if not (V is TJSONObject) then
      Continue;

    NestedObj := TJSONObject(V);
    for var ArrayKey in NestedArrayKeys do
    begin
      V := NestedObj.GetValue(ArrayKey);
      if V is TJSONArray then
      begin
        Arr := TJSONArray(V);
        Exit(True);
      end;
    end;
  end;

  Result := False;
end;

class procedure TGetItRestService.FetchPackages(const Request: TGetItRestRequest;
  const Target: TObjectDictionary<string, TGetItPackageInfo>; const OnLog: TGetItRestLogProc);
var
  HttpClient: THTTPClient;
  ReqStream: TStringStream;
  ReqHeaders: TNetHeaders;
  Resp: IHTTPResponse;
  RestUrl: string;
  Body: string;
  ContentText: string;
  JsonRoot: TJSONValue;
  Arr: TJSONArray;
  PageStart: Integer;
  PageSize: Integer;
  ItemsInPage: Integer;
begin
  RestUrl := CatalogInfoUrl(Request.ServiceUrl);
  ReqHeaders := [TNameValuePair.Create('Content-Type', 'application/x-www-form-urlencoded')];

  PageStart := 0;
  PageSize := 300;
  HttpClient := THTTPClient.Create;
  try
    repeat
      Body := BuildRestBody(Request, PageStart, PageStart + PageSize);
      OnLog(Format('REST body page: Start=%d End=%d', [PageStart, PageStart + PageSize]));

      ReqStream := TStringStream.Create(Body, TEncoding.UTF8);
      try
        Resp := HttpClient.Post(RestUrl, ReqStream, nil, ReqHeaders);
      finally
        ReqStream.Free;
      end;

      if Resp.StatusCode <> 200 then
        raise Exception.CreateFmt('REST call failed with status %d', [Resp.StatusCode]);

      ContentText := Resp.ContentAsString(TEncoding.UTF8);
      JsonRoot := TJSONObject.ParseJSONValue(ContentText);
      try
        if JsonRoot = nil then
          raise Exception.Create('Invalid JSON payload. Preview: ' + ResponsePreview(ContentText));

        if not TryGetArrayFromPayload(JsonRoot, Arr) then
          raise Exception.CreateFmt('Unexpected REST payload (%s). Preview: %s',
            [JsonRoot.ClassName, ResponsePreview(ContentText)]);

        ItemsInPage := Arr.Count;

        for var i := 0 to Arr.Count - 1 do
        begin
          if not (Arr.Items[i] is TJSONObject) then
            Continue;

          var Obj := Arr.Items[i] as TJSONObject;
          var Pkg := TGetItPackageInfo.Create;
          Pkg.Id := JsonValueToString(Obj, 'Id');
          Pkg.PackageId := JsonValueToString(Obj, 'PackageId');
          Pkg.Version := JsonValueToString(Obj, 'Version');
          Pkg.Name := JsonValueToString(Obj, 'Name');
          Pkg.Vendor := JsonValueToString(Obj, 'Vendor');
          Pkg.Description := JsonValueToString(Obj, 'Description');
          Pkg.TypeDescription := JsonValueToString(Obj, 'TypeDescription');
          Pkg.State := JsonValueToString(Obj, 'State');
          Pkg.Subscription := JsonValueToString(Obj, 'Subscription');
          ReadCategories(Obj, Pkg.CategoryIds, Pkg.CategoryNames);
          Pkg.LibCode := JsonValueToString(Obj, 'LibCode');
          Pkg.LibCodeName := JsonValueToString(Obj, 'LibCodeName');
          Pkg.LibSize := JsonValueToString(Obj, 'LibSize');
          Pkg.LibUrl := JsonValueToString(Obj, 'LibUrl');
          Pkg.VendorUrl := JsonValueToString(Obj, 'VendorUrl');
          Pkg.VersionTimestamp := JsonValueToString(Obj, 'VersionTimestamp');
          Pkg.Modified := JsonValueToString(Obj, 'Modified');

          if Pkg.Name.IsEmpty then
            Pkg.Name := TGetItCore.ExtractNameFromId(Pkg.Id);

          if Pkg.Id <> '' then
            Target.AddOrSetValue(Pkg.Id, Pkg)
          else
            Pkg.Free;
        end;
      finally
        JsonRoot.Free;
      end;

      Inc(PageStart, PageSize);
    until ItemsInPage < PageSize;
  finally
    HttpClient.Free;
  end;
end;

end.

