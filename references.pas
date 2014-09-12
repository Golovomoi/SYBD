unit references;

{$mode objfpc}{$H+}

interface

uses
	Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, DBGrids,
	ExtCtrls, Buttons, StdCtrls, DbCtrls, bddatamodule, sqldb, db, filters,
	MetaData, CardEdit ;

type

	{ TReferenceForm }

	TReferenceForm = class(TForm)
		Check_Id_Show: TCheckBox;
		Reference_Datasource: TDatasource;
		Reference_DB_Grid: TDBGrid;
		Filters_panel: TPanel;
		Refresh_Button: TSpeedButton;
		Add_Button: TSpeedButton;
		Change_Button: TSpeedButton;
		Delete_Button: TSpeedButton;
		Reference_SQL_Query: TSQLQuery;
		procedure Add_ButtonClick(Sender: TObject);
		procedure Change_ButtonClick(Sender: TObject);
		procedure Check_Id_ShowChange(Sender: TObject);
		procedure Reference_DB_GridDblClick(Sender: TObject);
		procedure Reference_DB_GridTitleClick(Column: TColumn);
		procedure Delete_ButtonClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure FormShow(Sender: TObject);
		procedure Refresh_ButtonClick(Sender: TObject);
		procedure Show_Table(ATable: TTable_Info);
		procedure generate_query();
		constructor create(ATable: TTable_Info); 
		procedure Refresh_Query();
	private
		FTable: TTable_Info;
		My_Filters: array of TFilter;
		One_Filter: TFilter;
		Reference_Filters: TFilter_Shell;
		Columns_Order_state: array of string;
		Current_Order_Column: integer; 
		{ private declarations }
	public
		FCurrent_Table: TTable_Info;
		selectstring: String;
		My_Select, My_From, My_Where, My_Order_By: string;
		{ public declarations }
	end;

var
	Reference_Form: TReferenceForm;
	
	

implementation

{$R *.lfm}

{ TReferenceForm }

procedure TReferenceForm.FormShow(Sender: TObject);
begin

end;

procedure TReferenceForm.Refresh_ButtonClick(Sender: TObject);
begin
	generate_query();
end;

procedure TReferenceForm.Show_Table(ATable: TTable_Info);
var
	i : integer;
begin
	self.Caption:= ATable.FTableRuName;
	FTable:= ATable;
	My_Select := ATable.Get_select();
	My_From := ATable.Get_From();
	My_Order_By:='';
	SetLength(Columns_Order_state, Length(ATable.FFields));
	Current_Order_Column:=0;
	for i:=0 to high(Columns_Order_state) do
		Columns_Order_state[i]:='';

	generate_query();
	Show;
end;

procedure TReferenceForm.generate_query();
var
	i: integer;
	Sort_Icon: string;
	Where_Planted: boolean;
	param: string;
	combination: string;
begin
	Where_Planted:= false;
	if Columns_Order_state[Current_Order_Column] <> '' then
		My_Order_By:= FTable.FFields[Current_Order_Column].Get_Order_By() +
			Columns_Order_state[Current_Order_Column];

	with Reference_SQL_Query do
	begin
		close;
		My_Where:= Reference_Filters.Get_Params();
		SQL.Text := My_Select + My_From + My_where;
		for i:=0 to high(Reference_Filters.FFilters_List) do		
		begin
			param:='param' + inttostr(i);
			if Reference_Filters.FFilters_List[i].FFilter_Edit.Caption <> '' then
				Params.ParamByName(param).AsString:=
					Reference_Filters.FFilters_List[i].Get_Edit_String;
		end;
		SQL.Text:= Sql.Text + My_Order_By;
		Open;
	end;

	Case Columns_Order_state[Current_Order_Column] of
		'': Sort_Icon:='';
		'DESC': Sort_Icon:='«';
		'ASC': Sort_Icon:='»';
	end;
	for i := 0 to high(FTable.Ffields) do
		Reference_DB_Grid.Columns[i].Title.Caption := FTable.FFields[i].FRu_Name;
	Reference_DB_Grid.Columns[Current_Order_Column].Title.Caption :=
		FTable.FFields[Current_Order_Column].FRu_Name + Sort_Icon;
	if Check_Id_Show.State = cbUnchecked then	
		Reference_DB_Grid.Columns[0].Visible:=False
	else
		Reference_DB_Grid.Columns[0].Visible:=true;
end;

constructor TReferenceForm.Create(Atable: TTable_Info);
begin
	FCurrent_Table:= ATable;
	inherited create(nil);
end;

procedure TReferenceForm.Refresh_Query;
begin
	generate_query();
end;



procedure TReferenceForm.FormCreate(Sender: TObject);
begin
	Reference_Filters:= TFilter_Shell.Create(Filters_Panel, FCurrent_Table);
end;

procedure TReferenceForm.Reference_DB_GridTitleClick(Column: TColumn);
begin
	if Current_Order_Column = Column.Index then
		case Columns_Order_state[Current_Order_Column] of
			'': Columns_Order_state[Current_Order_Column]:='ASC';
			'ASC': Columns_Order_state[Current_Order_Column]:= 'DESC';
			'DESC': Columns_Order_state[Current_Order_Column]:= '';
		end
	else
		Current_Order_Column:= Column.Index;
	generate_query();
end;

procedure TReferenceForm.Delete_ButtonClick(Sender: TObject);
var
	ForDelete: string;
begin
	ForDelete:= Reference_SQL_Query.FieldByName('id').AsString;
	if (MessageDlg('Вы действительно хотите удалить запись?',
		mtCustom, [mbYes, mbNo], 0)) = 6 then
		with Reference_SQL_Query do
		begin
			close;
			sql.Text:=' delete from ' + FCurrent_Table.FTable_Name + ' where id = ' + ForDelete;
			ExecSQL;
		end;
	Data_Module.SQLTransaction1.Commit;
	generate_query();
end;

procedure TReferenceForm.Add_ButtonClick(Sender: TObject);
var	
	Edit_Form: TCardEditForm;
begin
	Edit_Form:=TCardEditForm.create(FCurrent_Table, @Refresh_Query,
		'0');
	Edit_Form.show;
	
end;  

procedure TReferenceForm.Change_ButtonClick(Sender: TObject);
var	
	Edit_Form: TCardEditForm;
begin
	Edit_Form:=TCardEditForm.create(FCurrent_Table, @Refresh_Query,
		Reference_SQL_Query.FieldByName('ID').Text);
	Edit_Form.show;
	
end;

procedure TReferenceForm.Check_Id_ShowChange(Sender: TObject);
begin
	generate_query();
end;

procedure TReferenceForm.Reference_DB_GridDblClick(Sender: TObject);
begin
	Change_ButtonClick(Sender);
end;



end.



