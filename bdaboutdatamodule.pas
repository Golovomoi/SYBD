unit bdaboutDataModule;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, IBConnection, FileUtil;

type

  { TBDDataModule }

  TBDDataModule = class(TDataModule)
      IBConnection1: TIBConnection;
      SQLTransaction1: TSQLTransaction;
      procedure DataModuleCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  DataModule: TBDDataModule;

implementation

{$R *.lfm}

{ TBDDataModule }


procedure TBDDataModule.DataModuleCreate(Sender: TObject);
begin
    IBConnection1.Open;
end;

end.

