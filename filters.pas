unit Filters;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, DB, BufDataset, FileUtil, Forms, Controls, Graphics,
    Dialogs, DBGrids, StdCtrls, ExtCtrls, DBCtrls, MetaData, Buttons;

type

    { TFilter }
    delprocedure = procedure(Sender: TObject) of object;

    TFilter = class
        FFilter_Panel: Tpanel;
        FFilter_Edit: Tedit;
        FDelete_Button, Ftag_Button: TSpeedButton;
        Fselect_Field, FSelect_Condition, FCombination_Select: TComboBox;
        FTable_Info: TTable_Info;
        constructor Create(Apanel: TPanel; ATable: TTable_Info; del: delprocedure);
        destructor Destroy; override;
        procedure Get_Tag(Sender: TObject);
        procedure Copy_Filter(AFilter: TFilter);
        function Get_Param(): string;
        function Get_Field_Name(): string;
        function Get_Edit_String(): string;
        function get_combinatio(): string;
        procedure FSelect_Field_change(Sender: TObject);
    private

    public

    end;

    { TFilter_Shell }

    TFilter_Shell = class
        FFilters_Panel: TPanel;
        FTable_Info: TTable_Info;
        FCreate_Filters_Button: TSpeedButton;
        FFilters_Scrol: TScrollBar;
        FFilters_List: array of TFilter;
        constructor Create(sender: Tobject;Apanel: Tpanel; ATable: TTable_Info; adef_filters: array of integer);
        procedure Create_Filter(Sender: TObject);
        procedure Delete_Filter(Sender: TObject);
        procedure Change_Filters_Scrol(Sender: TObject);
        procedure Start_Filters_scrol(Sender: TObject; var DragObject: TDragObject);
        function Get_Params(): string;
        private
            fdef_filters: array of integer;
        public
    end;



implementation

{ TFilter_Shell }

constructor TFilter_Shell.Create(sender: Tobject; Apanel: Tpanel;
		ATable: TTable_Info; adef_filters: array of integer);
    var
        i: integer;
begin
    SetLength(fdef_filters, Length(adef_filters));
    for i:=0 to High(adef_filters) do
    fdef_filters[i]:= adef_filters[i];
    FFilters_Panel := Apanel;
    FTable_Info := Atable;
    FCreate_Filters_Button := TSpeedButton.Create(Apanel);

    with FCreate_Filters_Button do
    begin
        Parent := FFilters_Panel;
        Caption := 'Добавить Фильтр';
        top := 0;
        Left := FFilters_Panel.Width - 150;
        Width := FFilters_Panel.Width - left;
        Height := 50;
        OnClick := @Create_Filter;
        Anchors := [];
    end;
    FFilters_Scrol := TScrollBar.Create(FFilters_Panel);
    with FFilters_Scrol do
    begin
        Parent := FFilters_Panel;
        kind := sbVertical;
        top := 10;
        left := FCreate_Filters_Button.left - 25;
        Width := 25;
        Height := FFilters_Panel.Height - 20;
        min := 0;
        max := 0;
        OnStartDrag := @Start_Filters_scrol;
        OnChange := @Change_Filters_Scrol;
        Anchors := [];
    end;

    for i:=0 to High(adef_filters) do
    begin
        Create_Filter(sender);
        FFilters_List[i].FFilter_Edit.Caption:=inttostr(adef_filters[i]);
        FFilters_List[i].FCombination_Select.Caption:='or';
	end;

end;

procedure TFilter_Shell.Create_Filter(Sender: TObject);
begin
    SetLength(FFilters_List, Length(FFilters_List) + 1);
    FFilters_List[high(FFilters_List)] :=
        TFilter.Create(FFilters_Panel, FTable_Info, @Delete_Filter);
    if High(FFilters_List) > 3 then
    begin
        FFilters_List[high(FFilters_List)].FFilter_Panel.Top :=
            FFilters_List[high(FFilters_List)].FFilter_Panel.Top - FFilters_Scrol.Position;
        FFilters_Scrol.Max := FFilters_Scrol.Max + FFilters_List[high(FFilters_List)].FFilter_Panel.Height;
    end;
end;

procedure TFilter_Shell.Delete_Filter(Sender: TObject);
var
    i: integer;
    knpk: integer;
    Filter_Pointer: ^Tfilter;
begin
    knpk := (Sender as TSpeedButton).tag;
    for i := knpk to High(FFilters_List) - 1 do
    begin
        FFilters_List[i].Copy_Filter(FFilters_List[i + 1]);
        FFilters_List[i].FDelete_Button.tag := FFilters_List[i].FDelete_Button.tag - 1;
    end;
    FFilters_List[high(FFilters_List)].Destroy;
    FFilters_Panel.tag := FFilters_Panel.tag - 1;
    SetLength(FFilters_List, high(FFilters_List));
end;

procedure TFilter_Shell.Change_Filters_Scrol(Sender: TObject);
var
    i: integer;
begin
    for i := 0 to High(FFilters_List) do
        FFilters_List[i].FFilter_Panel.Top :=
            FFilters_List[i].FFilter_Panel.Top + FFilters_Scrol.tag - FFilters_Scrol.Position;
    FFilters_Scrol.Tag := FFilters_Scrol.Position;
end;


procedure TFilter_Shell.Start_Filters_scrol(Sender: TObject;
    var DragObject: TDragObject);
begin
    FFilters_Scrol.Tag := (Sender as TScrollBar).Position;
end;

function TFilter_Shell.Get_Params: string;
var
    i: integer;
    last_case: string;
    param: string;
begin
    begin
        Result := Result + ' where ';
        for i := 0 to high(FFilters_List) do
        begin
            param := 'param' + IntToStr(i);
            if FFilters_List[i].FFilter_Edit.Caption <> '' then
            begin
                last_case := FFilters_List[i].get_combinatio();
                Result += ' ' + FFilters_List[i].Get_Field_Name +
                    ' ' + FFilters_List[i].Get_Param + ' :' + param + ' ' + last_case;
            end;
        end;
    end;
    if Result = ' where ' then
        exit('');
    SetLength(Result, Length(Result) - Length(last_case));
end;



{ TFilter }

constructor TFilter.Create(Apanel: TPanel; ATable: TTable_Info; del: delprocedure);
var
    i: integer;
begin
    FTable_Info := Atable;
    FFilter_Panel := TPanel.Create(Apanel);
    with FFilter_Panel do
    begin
        Parent := Apanel;
        left := 0;
        Top := Apanel.tag * 50;
        Width := Apanel.Width - 175;
        Height := 50;
    end;


    FDelete_Button := TSpeedButton.Create(FFilter_Panel);
    with FDelete_Button do
    begin
        parent := FFilter_Panel;
        left := FFilter_Panel.Width - 60;
        top := 12;
        Width := 50;
        Height := 25;
        Caption := 'del';
        tag := Apanel.Tag;
        OnClick := del;
    end;


    Fselect_Field := TComboBox.Create(FFilter_Panel);
    with Fselect_Field do
    begin
        Parent := FFilter_Panel;
        left := 10;
        top := 12;
        Width := 150;
        Height := 25;
        OnChange := @FSelect_Field_change;
        ReadOnly := True;
        for i := 0 to High(ATable.FFields) do
        begin
            Items.Add(ATable.FFields[i].FRu_Name);
        end;
        Caption := Items[0];
    end;

    FSelect_Condition := TComboBox.Create(FFilter_Panel);
    with FSelect_Condition do
    begin
        Parent := FFilter_Panel;
        left := FSelect_Field.left + Fselect_Field.Width + 10;
        top := 12;
        Width := 150;
        Height := 25;
        ReadOnly := True;
        if ATable.FFields[0].FField_Type = FTStr then
        begin
            Items.Add('=');
            Items.Add('содержит');
            Items.Add('начинается с');
        end
        else
        begin
            Items.Add('=');
            Items.Add('>');
            Items.Add('<');
            Items.Add('>=');
            Items.Add('<=');
        end;
        Caption := Items[0];
    end;

        FFilter_Edit := TEdit.Create(FFilter_Panel);
    with FFilter_Edit do
    begin
        Parent := FFilter_Panel;
        left := FSelect_Condition.left + FSelect_Condition.Width + 10;
        Top := 12;
        Width := FFilter_Panel.Width div 3;
        Height := FFilter_Panel.Height - 10;
    end;

        FCombination_Select := TComboBox.Create(FFilter_Panel);
    with FCombination_Select do
    begin
        Parent := FFilter_Panel;
        left := FFilter_Edit.Left + FFilter_Edit.Width + 10;
        top := 12;
        Width := 100;
        Height := 25;
        Items.Add('and');
        items.Add('or');
        FCombination_Select.Caption := 'and';
        ReadOnly := True;
    end;
    Apanel.tag := Apanel.tag + 1;

end;

destructor TFilter.Destroy;
begin
    FFilter_Panel.Destroy;
    inherited Destroy;
end;

procedure TFilter.Get_Tag(Sender: TObject);
begin

    ShowMessage(IntToStr((Sender as TSpeedButton).tag));
end;

procedure TFilter.Copy_Filter(AFilter: TFilter);
var
    i: integer;
begin
    FFilter_Edit.Text := AFilter.FFilter_Edit.Text;
    FDelete_Button.Tag := AFilter.FDelete_Button.Tag;

    for i := 0 to AFilter.Fselect_Field.Items.Count - 1 do
        Fselect_Field.Items[i] := AFilter.Fselect_Field.Items[i];
    Fselect_Field.Caption := AFilter.Fselect_Field.Caption;

    for i := 0 to AFilter.FSelect_Condition.Items.Count - 1 do
        FSelect_Condition.Items[i] := AFilter.FSelect_Condition.Items[i];
    FSelect_Condition.Caption := AFilter.FSelect_Condition.Caption;
end;

function TFilter.Get_Param: string;
begin
    if (FTable_Info.FFields[Fselect_Field.ItemIndex].FField_Type = FTStr) or
        (FTable_Info.FFields[Fselect_Field.ItemIndex].FField_Type = FTDays) then
        Result := 'like'
    else
        Result := FSelect_Condition.Caption;

end;

function TFilter.Get_Field_Name: string;
begin
    if not FTable_Info.FReference_Table then
        Result := FTable_Info.FFields[Fselect_Field.ItemIndex].FName
    else
        Result := FTable_Info.FFields[Fselect_Field.ItemIndex].Get_Source_Table() +
            '.' + FTable_Info.FFields[Fselect_Field.ItemIndex].Get_Inner_Field();
end;

function TFilter.Get_Edit_String: string;
begin
    if FSelect_Condition.Caption = 'начинается с' then
        Result := FFilter_Edit.Caption + '%'
    else
    if FSelect_Condition.Caption = 'содержит' then
        Result := '%' + FFilter_Edit.Caption + '%'
    else
        Result := FFilter_Edit.Caption;
end;

function TFilter.get_combinatio: string;
begin
    Result := FCombination_Select.Caption;
end;

procedure TFilter.FSelect_Field_change(Sender: TObject);
begin
    with FSelect_Condition do
    begin
        items.Clear;
        if (FTable_Info.FFields[Fselect_Field.ItemIndex].FField_Type = FTStr) or
            (FTable_Info.FFields[Fselect_Field.ItemIndex].FField_Type = FTDays) then
        begin
            Items.Add('=');
            Items.Add('содержит');
            Items.Add('начинается с');
        end
        else
        begin
            Items.Add('=');
            Items.Add('>');
            Items.Add('<');
            Items.Add('>=');
            Items.Add('<=');
        end;
        Caption := Items[0];
    end;
end;

end.
