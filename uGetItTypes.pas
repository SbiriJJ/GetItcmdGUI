unit uGetItTypes;

interface

type
  TGetItPackageInfo = class
  public
    Id: string;
    PackageId: string;
    Version: string;
    Name: string;
    Vendor: string;
    Description: string;
    TypeDescription: string;
    State: string;
    Subscription: string;
    CategoryIds: string;
    CategoryNames: string;
    LibCode: string;
    LibCodeName: string;
    LibSize: string;
    LibUrl: string;
    VendorUrl: string;
    VersionTimestamp: string;
    Modified: string;
    InstalledVersion: string;
    LatestVersion: string;
    VersionStatus: string;
  end;

  TListSource = (lsUnknown, lsGetItCmd, lsRest);

implementation

end.
