unit MainUnit;
//tnotifyevent
{$mode objfpc}{$H+}

interface

uses
	Classes, SysUtils, sqldb, IBConnection, db, FileUtil, SynMemo,
	SynHighlighterSQL, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
	Buttons, DBGrids, DbCtrls, Menus, MetaData, references, bddatamodule, Schedule_Edit;

type

	{ TMySql }

	TMySql = class(TForm)
SpeedButton1: TSpeedButton;
StartDatasource: TDatasource;
		Start_Data_Source: TDatasource;
		Main_DB_Grid: TDBGrid;
		Host_Name: TLabeledEdit;
		Connect_Button: TSpeedButton;
		Main_menu: TMainMenu;
		File_Menu: TMenuItem;
		Help_Menu: TMenuItem;
		File_Exit: TMenuItem;
		Author_Menu: TMenuItem;
		References_Tables: TMenuItem;
		Send_Query_Button: TSpeedButton;
		StartQuery: TSQLQuery;
		Main_Syn_Memo: TSynMemo;
		Sql_Syn: TSynSQLSyn;
		User_Name: TLabeledEdit;
		Password: TLabeledEdit;
		DB_Name: TLabeledEdit;
		procedure Author_MenuClick(Sender: TObject);
		procedure Connect_ButtonClick(Sender: TObject);
		procedure File_ExitClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure Send_Query_ButtonClick(Sender: TObject);
		procedure Create_Reference_Menu();
		procedure Reference_Table_Show(Sender: Tobject);
procedure SpeedButton1Click(Sender: TObject);
	private
		{ private declarations }
	public
		{ public declarations }
	end;

var
	My_Sql: TMySql;
	About_Tables_Items: array of TMenuItem;

implementation

{$R *.lfm}

{ TMySql }

procedure TMySql.Connect_ButtonClick(Sender: TObject);
begin
    
	Data_Module.IBConnection1.UserName:= User_Name.Text;
    Data_Module.IBConnection1.Password:= Password.Text;
    Data_Module.IBConnection1.HostName:= Host_Name.text;
    Data_Module.IBConnection1.DatabaseName:= DB_Name.Text;
end;

procedure TMySql.Author_MenuClick(Sender: TObject);
begin
	ShowMessage('Кузнецов Игорь Русланович Б8103а-2');
end;

procedure TMySql.Create_Reference_Menu();
var
	i: integer;
	My_Menu_Item: TMenuItem;
begin
	for i:=0 to High(My_Tables) do
	begin
		My_Menu_Item:= TMenuItem.Create(References_Tables);

		with My_Menu_Item do
		begin
			caption:='&'+My_Tables[i].FTableRuName;
			name:='Menu' + My_Tables[i].FTable_Name;
			tag:=i;
			OnClick:= @Reference_Table_Show;
		end;
		SetLength(About_Tables_Items, length(About_Tables_Items)+1);
		About_Tables_Items[High(About_Tables_Items)]:=My_Menu_Item;

	end;
	References_Tables.Add(About_Tables_Items);
end;

procedure TMySql.Reference_Table_Show(Sender: Tobject);
var
	Table_Discription : TReferenceForm;
begin
	Table_Discription := TReferenceForm.Create(My_Tables[(Sender as TMenuItem).Tag]);
	Table_Discription.Show_Table(My_Tables[(Sender as TMenuItem).Tag]);
end;

procedure TMySql.SpeedButton1Click(Sender: TObject);
begin
	Schedule_Edit_form.show;
end;



procedure TMySql.File_ExitClick(Sender: TObject);
begin
	Application.Terminate;
end;

procedure TMySql.FormCreate(Sender: TObject);
begin
	Create_Reference_Menu();
end;


procedure TMySql.Send_Query_ButtonClick(Sender: TObject);
begin
	with StartQuery do begin
		close;
		SQL.Text:= Main_Syn_Memo.Text;
		Open;
	end;
end;

end.
						 {
                         query datasource на форме справочника
                         класс формы, много форм одного класса
                         reference form
                         на форме дбгрид. квери, datasource на один connection
                         создать 3 модуль с формой и модлуль в котором лежат все конекшены
                         модуль данных -DATAmodule
                         на нем конекшн и транзакции
                         завести в программе
                         создать форму записать селект в квери, квери опен, форм шоу
                         }//procedure TMySql.GroupsTableMenuClick(Sender: TObject);//var//  TableDiscription: TReferenceForm;//begin//   TableDiscription:= TReferenceForm.Create(Nil);//   TableDiscription.show;//end;









