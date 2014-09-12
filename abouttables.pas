unit aboutTables;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, DBGrids,
  bdaboutDataModule, sqldb, db ;

type

  { TReferenceForm }

  TReferenceForm = class(TForm)
      Datasource1: TDatasource;
      DBGrid1: TDBGrid;
      SQLQuery1: TSQLQuery;
      procedure FormCreate(Sender: TObject);
      procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
      selectstring: String;
    { public declarations }
  end;

var
  ReferenceForm: TReferenceForm;

implementation

{$R *.lfm}

{ TReferenceForm }

procedure TReferenceForm.FormShow(Sender: TObject);
begin
    //with SQLQuery1 do
    //begin
    //    close;
    //    SQL.Text := 'select * from Groups;';
    //    Open;
    //end;
end;

procedure TReferenceForm.FormCreate(Sender: TObject);
begin

end;

end.

