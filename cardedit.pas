unit CardEdit;

{$mode objfpc}{$H+}

interface

uses
	Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, DbCtrls,
	Buttons, ExtCtrls, bddatamodule, db, sqldb, MetaData, StdCtrls;

type
	TInsert_help = record
		FLookUpComboBox: TDBLookupComboBox;
		FLst_Source: TDataSource;
		FLst_query: TSQLQuery;
	end;

	TCom_Proc = procedure of Object;
	{ TCardEditForm }

	TCardEditForm = class(TForm)
		Datasource1: TDatasource;
		Card_edit_datasource: TDatasource;
		Save_Button: TSpeedButton;
		Edit_Box: TScrollBox;
		SQLQuery1: TSQLQuery;
		Card_Edit_SQLQuery: TSQLQuery;
		procedure FormCreate(Sender: TObject);
		procedure FormShow(Sender: TObject);
		procedure Edit_PanelClick(Sender: TObject);
		procedure Save_ButtonClick(Sender: TObject);
		constructor create(Atable: TTable_Info; Aproc: TCom_Proc; ACurrent_Record_ID: string);
	private
		FCurrent_Table: TTable_Info; 
		FRefresh_Reference: TCom_Proc;
		FCurrent_Record_ID: string;
		FInsert_list: array of TInsert_help;
		FEdits_list: array of Tedit;
		FGenerator_Value: string;
        FLabels_list: array of TLabel;
		{ private declarations }
	public
		{ public declarations }
	end;
const
	trash_Value = '-300';
var
	CardEditForm: TCardEditForm;

implementation

{$R *.lfm}

{ TCardEditForm }

procedure TCardEditForm.FormShow(Sender: TObject);
var
	i: integer;
begin
	if FCurrent_Record_ID = '0' then
	begin
		FCurrent_Record_ID:= trash_Value;
		Self.Caption:='Добавление';
	end
    else
    self.Caption:= ' Изменение';
	with Card_Edit_SQLQuery do
	begin
		close;
		sql.Text:='select * from ' + FCurrent_Table.FTable_Name + ' where id = ' + FCurrent_Record_ID;
		open;
	end;
	for i:= 1 to High(FCurrent_Table.FFields) do
	begin
        SetLength(FLabels_list, Length(FLabels_list)+1);
        FLabels_list[High(FLabels_list)]:= TLabel.Create(Edit_Box);
        with FLabels_list[High(FLabels_list)] do
        begin
        Parent:= Edit_Box;
        top := 10 + ((i-1)*2)*25;
        left:=10;
        Height:=25;
        Width:=200;
        Caption:= FCurrent_Table.FFields[i].FRu_Name + ':';
        end;
		if (FCurrent_Table.FFields[i] is TReference_Field_Info) then
		begin
			SetLength(FInsert_list, Length(FInsert_list)+1);
			FInsert_list[High(FInsert_list)].FLst_query := TSQLQuery.Create(Edit_Box);
			with FInsert_list[High(FInsert_list)].FLst_query do
			begin
				DataBase:=Data_Module.IBConnection1;
				Transaction := Data_Module.SQLTransaction1;
				close;
				sql.Text:= 'select * from ' + FCurrent_Table.FFields[i].Get_Source_Table;
				open;
			end;

			FInsert_list[High(FInsert_list)].FLst_Source := TDataSource.create(Edit_Box);
			FInsert_list[High(FInsert_list)].FLst_Source.DataSet := FInsert_list[High(FInsert_list)].FLst_query;
				   
			FInsert_list[High(FInsert_list)].FLookUpComboBox:= TDBLookupComboBox.Create(Edit_Box);
			with FInsert_list[High(FInsert_list)].FLookUpComboBox do
			begin
				Parent:= Edit_Box;
				top:= 10 + (i*2-1)*25;
				left:= 10;
				Height:= 25;
				DataSource:= Card_edit_datasource;
				ListSource:= FInsert_list[High(FInsert_list)].FLst_Source;
				Width:= 200;
				ListField:= FCurrent_Table.FFields[i].Get_Inner_Field;
				DataField:= FCurrent_Table.FFields[i].FName;
				KeyField:= 'ID'; 
                Style:=csDropDownList;
			end;
		end
		else
		begin
			SetLength(FEdits_list, Length(FEdits_list)+1);
			FEdits_list[high(FEdits_list)] := TEdit.Create(Edit_Box);
			with FEdits_list[high(FEdits_list)] do 
			begin
				parent:= Edit_Box;
				top:=10+ (i*2-1)*25;
				left:= 10;
				Height:= 25;
				Width:=200;
				Caption:= Card_Edit_SQLQuery.FieldByName(FCurrent_Table.FFields[i].FName).Text;
				tag:=i;
			end; 

		end;
	end;

end;

procedure TCardEditForm.Edit_PanelClick(Sender: TObject);
begin

end;

procedure TCardEditForm.FormCreate(Sender: TObject);
begin

end;

procedure TCardEditForm.Save_ButtonClick(Sender: TObject);
var
	i: integer;
	param: string;
	Sql_Edit: string;
    Empty_Field: boolean;

begin
    for i:=0 to High(FInsert_list) do
    if FInsert_list[i].FLookUpComboBox.Caption = '' then
    begin
        ShowMessage('заполните все поля');
        exit;
    end;
    for i:=0 to High(FEdits_list) do
    if Fedits_List[i].Caption = '' then
    begin
        ShowMessage('заполните все поля');
        exit;
    end;
    if (FCurrent_Record_ID = trash_Value) and (Length(FEdits_list)=0) then
	begin
		with SQLQuery1 do
		begin
			close;
			sql.Text:= 'select next value for ' + FCurrent_Table.FGenerator_Name + ' from RDB$DATABASE';
			open;
			FGenerator_Value:= FieldByName('Gen_id').Text;
		end;
		with Card_Edit_SQLQuery do
		begin
			FieldByName('Id').Text:= FGenerator_Value;
			open;
			ApplyUpdates;
		end;
	end
	else
		with Card_Edit_SQLQuery do
		begin
			open; 
			ApplyUpdates;
		end;
	if length(FEdits_list) > 0 then
		with Card_Edit_SQLQuery do
		begin
			close;
			if FCurrent_Record_ID = trash_Value then
				sql.Text:=' insert into ' + FCurrent_Table.FTable_Name + ' values( next value for '
					+ FCurrent_Table.FGenerator_Name + ','
			else
				Sql.Text:=' update ' + FCurrent_Table.FTable_Name + ' set ';
			for i:=0 to High(FEdits_list) do
			begin
				param:= 'param' + IntToStr(i);
				if FCurrent_Record_ID = trash_Value then 
					sql.Text:= sql.Text + ' :' + param + ','
				else
					Sql.Text:= Sql.Text + FCurrent_Table.FFields[FEdits_list[i].tag].FName 
						+ ' = :' + param + ',';

				Params.ParamByName(param).AsString:=
					FEdits_list[i].Caption;

			end;
			//sql.Text:=Copy(sql.Text, 1, Length(sql.Text)-2);
			sql.Text:= Copy(sql.Text, 1, Length(SQL.Text)-3);
			ShowMessage(sql.Text);
			if FCurrent_Record_ID = trash_Value then
				sql.Text:= sql.Text + ' )' 
			else
				Sql.Text:= Sql.Text + ' where id = ' + FCurrent_Record_ID;
			ExecSQL;
		end;
	Data_Module.SQLTransaction1.Commit;  
	FRefresh_Reference;
	Self.Close;
end;

constructor TCardEditForm.create(Atable: TTable_Info; Aproc: TCom_Proc; 
	ACurrent_Record_ID: string);
begin
	FCurrent_Table:= Atable;
	FRefresh_Reference:= Aproc;
	FCurrent_Record_ID:=ACurrent_Record_ID;
	Inherited create(nil);
end;


end.































