unit Schedule_Edit;

{длинный сетленг, два sql}
{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, DB, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
    Grids, ExtCtrls, Buttons, StdCtrls, MetaData, Clipbrd, Filters, CardEdit, sch_export,
    bddatamodule, ConflictsMeta, ConflictsTree, math;

type

    { TSchedule_Edit_form }



    TSchedule_Edit_form = class(TForm)
        CheckGroup1: TCheckGroup;
        ConflictsTreeBtn: TButton;
        Filters_panel: TPanel;
        Horisontal_fields: TComboBox;
        SaveDialog: TSaveDialog;
        Save_Button: TSpeedButton;
        vertical_fields: TComboBox;
        Schedule_edit_Datasource: TDatasource;
        Schedule_edit_Edit_SQLQuery: TSQLQuery;
        Schedule_Grid: TDrawGrid;
        Button_Show: TSpeedButton;
        procedure CheckGroup1ItemClick(Sender: TObject; Index: integer);
        procedure ConflictsTreeBtnClick(Sender: TObject);
        procedure Filters_panelClick(Sender: TObject);
        procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
        procedure FormCreate(Sender: TObject);
        procedure Schedule_GridClick(Sender: TObject);
        procedure Schedule_GridDblClick(Sender: TObject);
        procedure Schedule_GridDrawCell(Sender: TObject; aCol, aRow: integer;
            aRect: TRect; aState: TGridDrawState);
        procedure FormShow(Sender: TObject);
        procedure Button_ShowClick(Sender: TObject);
        procedure Schedule_GridMouseMove(Sender: TObject; Shift: TShiftState;
            X, Y: integer);
        procedure Show_schedule();
        procedure Make_Title_array(var AFields_Array: TTitle_Array;
            AField_Index: integer);
        procedure create_card(Sender: TObject);
        procedure Create_Cell_Edit_Button();
        procedure Create_Cell_add_Button();
        procedure Create_Delete_Button();
        procedure Delete_Record(Sender: TObject);
        procedure Save_ButtonClick(Sender: TObject);
        procedure Replace_buttons();
    private
        FMy_select: string;
        FGrid_Cells_Values: TMy_Grid;
        FHorisontal_Fields: TTitle_Array;
        FVertical_Fields: TTitle_Array;
        FMy_From: string;
        FMy_Where: string;
        My_Order_By: string;
        schedule_filter: TFilter_Shell;
        Change_Buttons: array of TSpeedButton;
        Add_Buuton, Change_Button, Delete_Button: TSpeedButton;
        { private declarations }
    public
        { public declarations }
    end;


var
    Schedule_Edit_form: TSchedule_Edit_form;
    P_Records: array of TGrid_Record;
    M_X, M_Y, Size_col, Size_row: integer;
    Selected_fields_count: integer;


implementation

{$R *.lfm}

{ TSchedule_Edit_form }

procedure TSchedule_Edit_form.FormShow(Sender: TObject);
    var
        i: integer;
    begin
        Show_schedule();
    end;

procedure TSchedule_Edit_form.Button_ShowClick(Sender: TObject);
    var
        i: integer;
    begin
        Show_schedule();
        for i := 0 to CheckGroup1.Items.Count - 1 do
        begin
            CheckGroup1.Checked[i] :=
                not ((i = vertical_fields.Items.IndexOf(vertical_fields.Caption)) or
                (i = Horisontal_fields.Items.IndexOf(Horisontal_fields.Caption)));
            CheckGroup1.CheckEnabled[i] :=
                not ((i = vertical_fields.Items.IndexOf(vertical_fields.Caption)) or
                (i = Horisontal_fields.Items.IndexOf(Horisontal_fields.Caption)));
        end;
        Selected_fields_count := Length(Schedule_Table.FFields) - 2;
    end;

procedure TSchedule_Edit_form.Schedule_GridMouseMove(Sender: TObject;
    Shift: TShiftState; X, Y: integer);
    begin
        M_X := x;
        M_Y := y;
        Replace_buttons();
    end;

procedure TSchedule_Edit_form.Show_schedule;
    var
        i, j, k, V_ind, H_ind: integer;
        param: string;
    begin
        Schedule_Grid.Clear;
        SetLength(FGrid_Cells_Values, 0);
        V_ind := vertical_fields.ItemIndex;
        H_ind := Horisontal_fields.ItemIndex;
        Make_Title_array(FVertical_Fields, V_ind);
        Make_Title_array(FHorisontal_Fields, H_ind);
        Schedule_Grid.ColCount := Length(FHorisontal_Fields);
        Schedule_Grid.RowCount := Length(FVertical_Fields);

        with Schedule_edit_Edit_SQLQuery do
        begin

            My_order_By := ' order by ' + Schedule_Table.FFields[V_ind].FName +
                ' , ' + Schedule_Table.FFields[H_ind].FName + ' ';
            FMy_select := Schedule_Table.Get_Schedule_select();
            FMy_From := Schedule_Table.Get_From();
            FMy_Where := schedule_filter.Get_Params();
            //Clipboard.AsText:=( FMy_select + FMy_From + FMy_Where + My_Order_By);
            Close;
            sql.Text := FMy_select + FMy_From + FMy_Where + My_Order_By;
            for i := 0 to high(schedule_filter.FFilters_List) do
            begin
                param := 'param' + IntToStr(i);
                if schedule_filter.FFilters_List[i].FFilter_Edit.Caption <> '' then
                    Params.ParamByName(param).AsString :=
                        schedule_filter.FFilters_List[i].Get_Edit_String;
            end;
            Open;
            First;
            SetLength(FGrid_Cells_Values, Length(FVertical_Fields));
            for i := 0 to High(FVertical_Fields) do
                SetLength(FGrid_Cells_Values[i], Length(FHorisontal_Fields));

            for i := 1 to High(FVertical_Fields) do
            begin
                j := 1;
                while j <= High(FHorisontal_Fields) do
                begin
                    if (FieldByName(Schedule_Table.FFields[V_ind].FName).AsInteger =
                        FVertical_Fields[i].FId) and
                        (FieldByName(Schedule_Table.FFields[H_ind].FName).AsInteger =
                        FHorisontal_Fields[j].FId) then
                    begin
                        if EOF then
                            Break;
                        P_Records := FGrid_Cells_Values[i][j].FRecords;
                        SetLength(P_Records, Length(P_Records) + 1);
                        for k := 0 to High(Schedule_Table.FFields) do
                        begin
                            with P_Records[High(P_Records)] do
                            begin
                                SetLength(FValues, Length(FValues) + 1);
                                FValues[high(FValues)] :=
                                    FieldByName(
                                    Schedule_Table.FFields[k].Get_Inner_Field).AsString;

                            end;
                            FGrid_Cells_Values[i][j].max_text_width:=Max(
                            FGrid_Cells_Values[i][j].max_text_width,
                            Schedule_Grid.Canvas.TextWidth(P_Records[High(P_Records)].FValues[k] +
                            Schedule_Table.FFields[k].FRu_Name));
						end;
						FGrid_Cells_Values[i][j].max_text_height:=
                        Schedule_Grid.Canvas.TextHeight(P_Records[High(P_Records)].FValues[0]);

                        FGrid_Cells_Values[i][j].FRecords := P_Records;
                        Next;
                        Schedule_Grid.RowHeights[i]:=FGrid_Cells_Values[i][j].max_text_height *
                        Selected_fields_count;
                        Schedule_Grid.ColWidths[j]:=
                        Schedule_Grid.Canvas.TextWidth(FHorisontal_Fields[j].FName);
                    end
                    else
                    begin
                        if EOF then
                            Break;
                        Inc(j);
                    end;
                end;
                if EOF then
                    break;
            end;
        end;

        //for i := 0 to High(FVertical_Fields) do
        //    Schedule_Grid.RowHeights[i] := 20 * Length(Schedule_Table.FFields);
        //for i := 0 to High(FHorisontal_Fields) do
        //    Schedule_Grid.ColWidths[i] := 300;
        Schedule_Grid.Invalidate;
    end;

procedure TSchedule_Edit_form.Make_Title_array(var AFields_Array: TTitle_Array;
    AField_Index: integer);
    var
        i: integer;
    begin
        SetLength(AFields_Array, 1);
        with Schedule_edit_Edit_SQLQuery do
        begin

            Close;
            SQL.Text := ' select * from ' +
                Schedule_Table.FFields[AField_Index].Get_Source_Table +
                '  order by id ';
            Open;
            First;
            while not EOF do
            begin
                SetLength(AFields_Array, Length(AFields_Array) + 1);
                AFields_Array[High(AFields_Array)].FName :=
                    FieldByName(Schedule_Table.FFields[
                    AField_Index].Get_Inner_Field).AsString;
                AFields_Array[High(AFields_Array)].FID :=
                    FieldByName('id').AsInteger;
                Next;
            end;
        end;

    end;

procedure TSchedule_Edit_form.create_card(Sender: TObject);
    var
        Edit_card: TCardEditForm;
    begin
        Edit_card := TCardEditForm.Create(Schedule_Table, @Show_schedule,
            IntToStr((Sender as TSpeedButton).Tag));
        Edit_card.Show;
    end;


procedure TSchedule_Edit_form.Create_Cell_Edit_Button;
    var
        i: integer;
        cell_rect: Trect;
    begin
        Change_Button := TSpeedButton.Create(Schedule_Grid);
        with Change_Button do
        begin
            parent := Schedule_Grid;
            left := -100;
            top := -100;
            Width := 20;
            Height := 20;
            Caption := 'c';
            tag := 0;
            OnClick := @create_card;
        end;

    end;

procedure TSchedule_Edit_form.Create_Cell_add_Button;
    var
        i: integer;
        cell_rect: Trect;
    begin
        Add_Buuton := TSpeedButton.Create(Schedule_Grid);
        with Add_Buuton do
        begin
            parent := Schedule_Grid;
            left := -100;
            top := -100;
            Width := 20;
            Height := 20;
            Caption := 'a';
            tag := 0;
            OnClick := @create_card;
        end;

    end;

procedure TSchedule_Edit_form.Create_Delete_Button;
    begin

        Delete_Button := TSpeedButton.Create(Schedule_Grid);
        with Delete_Button do
        begin
            parent := Schedule_Grid;
            left := -100;
            top := -100;
            Width := 20;
            Height := 20;
            Caption := 'd';
            tag := 0;
            OnClick := @Delete_Record;
        end;

    end;

procedure TSchedule_Edit_form.Delete_Record(Sender: TObject);
    var
        ForDelete: string;
    begin
        ForDelete := Schedule_edit_Edit_SQLQuery.FieldByName('id').AsString;
        if (MessageDlg('Вы действительно хотите удалить запись?', mtCustom,
            [mbYes, mbNo], 0)) = 6 then
            with Schedule_edit_Edit_SQLQuery do
            begin
                Close;
                sql.Text := ' delete from ' + Schedule_Table.FTable_Name +
                    ' where id = ' + IntToStr((Sender as TSpeedButton).tag);
                ExecSQL;
            end;
        Data_Module.SQLTransaction1.Commit;
        Show_schedule();
    end;

procedure TSchedule_Edit_form.Save_ButtonClick(Sender: TObject);
    begin
        if SaveDialog.Execute then
            case SaveDialog.FilterIndex of
                1: SaveHTML(SaveDialog.FileName, FGrid_Cells_Values, FHorisontal_Fields,
                        FVertical_Fields, CheckGroup1);
                2: SaveExcel(SaveDialog.FileName, FGrid_Cells_Values, FHorisontal_Fields,
                        FVertical_Fields, CheckGroup1);
            end;

    end;

procedure TSchedule_Edit_form.Replace_buttons;
    var
        Pcol, Prow, i: integer;
        Cur_rect: TRect;
    begin
        Schedule_Grid.MouseToCell(M_X, M_Y, Pcol, Prow);
        Cur_rect := Schedule_Grid.CellRect(Pcol, Prow);
        if Length(FGrid_Cells_Values[Prow][Pcol].FRecords) > 0 then
        begin
            Change_Button.Left := Cur_rect.Right - 20;
            Add_Buuton.Left := Cur_rect.Right - 20;
            Delete_Button.Left := Cur_rect.Right - 20;

        end;
  {  if (Length(FGrid_Cells_Values[Pcol][Prow].FRecords) > 0) and
        ((M_Y - Cur_rect.top) div
        (Schedule_Grid.Canvas.TextHeight(FGrid_Cells_Values[Pcol]
        [Prow].FRecords[0].FValues[0]) * Selected_fields_count) <
        (Length(FGrid_Cells_Values[Pcol][Prow].FRecords))) then
    begin
         Change_Button.Left := Cur_rect.Right - 20;
         Add_Buuton.Left := Cur_rect.Right - 20;
         Delete_Button.Left := Cur_rect.Right - 20;
         if (text_h * Selected_fields_count) <=0 then exit;
        text_h := Schedule_Grid.Canvas.TextHeight(
            FGrid_Cells_Values[Pcol][Prow].FRecords[0].FValues[0]);
        change_Button.tag :=
            StrToInt(FGrid_Cells_Values[Pcol][Prow].FRecords[
            ((M_Y - Cur_rect.top) div (text_h * Selected_fields_count))].FValues[0]);
        Delete_Button.Tag :=
            StrToInt(FGrid_Cells_Values[Pcol][Prow].FRecords[
            ((M_Y - Cur_rect.top) div (text_h * Selected_fields_count))].FValues[0]);
        ;
        Change_Button.top := Cur_rect.Top +
            (((M_Y - Cur_rect.top) div (text_h * Selected_fields_count)) +1) *
            (text_h * Selected_fields_count) - 20;
        Delete_Button.top := Cur_rect.Top +
            (((M_Y - Cur_rect.top) div (text_h * Selected_fields_count)) +1) *
            (text_h * Selected_fields_count) - 20 * 2;
        Add_Buuton.top := Cur_rect.Top +
            (((M_Y - Cur_rect.top) div (text_h * Selected_fields_count)) +1) *
            (text_h * Selected_fields_count) - 20 * 3;
    end
    else
    begin
        Change_Button.Left := -1000;
         Add_Buuton.Left := -1000;
         Delete_Button.Left := -1000;
    end;   }

    end;

procedure TSchedule_Edit_form.Schedule_GridDrawCell(Sender: TObject;
    aCol, aRow: integer; aRect: TRect; aState: TGridDrawState);
    var
        i, j, k, Count, rec_count: integer;
    begin
        if (aCol = 0) and (aRow = 0) then
        begin
            Schedule_Grid.Canvas.Colors[0, 0] := TColorToFPColor(clBlack);
            FGrid_Cells_Values[0][0].max_text_height:=20;
            FGrid_Cells_Values[0][0].max_text_width:=300;
            Exit;
        end
        else
        if (aRow = 0) then
        begin
            Schedule_Grid.Canvas.TextOut(aRect.Left, aRect.top,
            FHorisontal_Fields[acol].FName);
            Schedule_Grid.RowHeights[0]:=max(Schedule_Grid.RowHeights[0],
            Schedule_Grid.Canvas.TextHeight(FHorisontal_Fields[acol].FName));
            FHorisontal_Fields[aCol].max_text_width:= Schedule_Grid.Canvas.TextWidth(
            FHorisontal_Fields[aCol].FName);
            FGrid_Cells_Values[0][aCol].max_text_height:=Schedule_Grid.RowHeights[acol];
        end
        else
        if (aCol = 0) then
        begin
            Schedule_Grid.Canvas.TextOut(aRect.Left, aRect.top,
                FVertical_Fields[arow].FName);
            //Schedule_Grid.RowHeights[arow]:=
            //Schedule_Grid.Canvas.TextHeight(FVertical_Fields[arow].FName);
            Schedule_Grid.ColWidths[0]:=
            max(Schedule_Grid.Canvas.TextWidth(FVertical_Fields[arow].FName),
            Schedule_Grid.ColWidths[0]);
            FGrid_Cells_Values[aRow][aCol].max_text_height:= Schedule_Grid.RowHeights[aRow];
        end
        else
        begin
            Count := 0;
            P_Records := FGrid_Cells_Values[aRow][aCol].FRecords;
            if length(P_Records) > 0 then
            begin
                FGrid_Cells_Values[aRow][aCol].max_text_height:=
                    Schedule_Grid.Canvas.TextHeight(P_Records[0].FValues[0]);
                FGrid_Cells_Values[aRow][aCol].max_text_width:=0;
                for k := 0 to High(P_Records) do
                begin
                    for i := 0 to High(Schedule_Table.FFields) do
                    begin
                        rec_count :=
                        (k * Length(Schedule_Table.FFields) + i - Count) *
                        FGrid_Cells_Values[aRow][aCol].max_text_height;
                        if CheckGroup1.Checked[i] then
                        begin
                            FGrid_Cells_Values[aRow][aCol].max_text_width:=Max(
                            FGrid_Cells_Values[aRow][aCol].max_text_width,
                            Schedule_Grid.Canvas.TextWidth(P_Records[k].FValues[i] +
                            Schedule_Table.FFields[i].FRu_Name + ': '));
                            Schedule_Grid.Canvas.TextOut(aRect.Left, aRect.top + rec_count,
                                Schedule_Table.FFields[i].FRu_Name +
                                ': ' + P_Records[k].FValues[i]);
                        end
                        else
                            Inc(Count);

                    end;
                    Schedule_Grid.Canvas.line(aRect.Left, aRect.Top + rec_count +
                        FGrid_Cells_Values[aRow][aCol].max_text_height - 1,
                        aRect.Right, aRect.Top + rec_count +
                        FGrid_Cells_Values[aRow][aCol].max_text_height - 1);
                end;
                //Schedule_Grid.RowHeights[aRow]:=P_Records[0].text_height*Selected_fields_count;
			end
            else
            begin
                FGrid_Cells_Values[aRow][aCol].max_text_height:=Schedule_Grid.RowHeights[aRow];
			end;

            FGrid_Cells_Values[aRow][aCol].FRecords:= P_Records;

            if Length(P_Records) * FGrid_Cells_Values[aRow][aCol].max_text_height *
            Selected_fields_count> Schedule_Grid.RowHeights[arow] then
            begin
                //ShowMessage(inttostr(Schedule_Grid.RowHeights[aRow]));
                Schedule_Grid.Canvas.brush.Color := ClBlack;
                Schedule_Grid.Canvas.Polygon([Point(aRect.Right, aRect.Bottom),
                    Point(aRect.Right - 15, aRect.Bottom),
                    Point(aRect.Right, aRect.Bottom - 15)]);
                schedule_grid.Canvas.Brush.Color := clWhite;
            end;


        end;
    end;

procedure TSchedule_Edit_form.FormCreate(Sender: TObject);
    var
        i: integer;
    begin
        CheckGroup1.Columns := 2;
        for i := 0 to High(Schedule_Table.FFields) do
        begin
            CheckGroup1.Items.Add(Schedule_Table.FFields[i].FRu_Name);
            vertical_fields.Items.Add(Schedule_Table.FFields[i].FRu_Name);
            Horisontal_fields.Items.Add(Schedule_Table.FFields[i].FRu_Name);
            CheckGroup1.Checked[i] := True;
        end;
        with vertical_fields do
            Caption := Items.ValueFromIndex[1];

        with Horisontal_fields do
            Caption := Items.ValueFromIndex[2];

        schedule_filter := TFilter_Shell.Create(Filters_panel, Schedule_Table);
        Button_ShowClick(Sender);
        Create_Cell_add_Button();
        Create_Cell_Edit_Button();
        Create_Delete_Button();
    end;

procedure TSchedule_Edit_form.Schedule_GridClick(Sender: TObject);
    var
        psize_col, psize_row: integer;
    begin

    end;

procedure TSchedule_Edit_form.Schedule_GridDblClick(Sender: TObject);
    begin
        Schedule_Grid.MouseToCell(M_X, M_Y, size_col, size_row);
        if Schedule_Grid.RowHeights[Size_row] > (FGrid_Cells_Values[Size_row][Size_col].max_text_height) *
        Selected_fields_count then
            Schedule_Grid.RowHeights[Size_row]:= (FGrid_Cells_Values[Size_row][Size_col].max_text_height) *
                Selected_fields_count
        else
        if Length(FGrid_Cells_Values[Size_row][Size_col].FRecords) > 0 then
        Schedule_Grid.RowHeights[Size_row]:= (FGrid_Cells_Values[Size_row][Size_col].max_text_height) *
                Selected_fields_count* Length(FGrid_Cells_Values[Size_row][Size_col].FRecords);

        //ShowMessage(inttostr(Schedule_Grid.ColWidths[Size_col]));
        //ShowMessage(IntToStr(FGrid_Cells_Values[Size_row][Size_col].max_text_width));
        if Schedule_Grid.ColWidths[Size_col] < FGrid_Cells_Values[Size_row][Size_col].max_text_width then
        //ShowMessage('hi')
            Schedule_Grid.ColWidths[Size_col] := FGrid_Cells_Values[Size_row][Size_col].max_text_width
        else
            Schedule_Grid.ColWidths[Size_col] := FHorisontal_Fields[Size_col].max_text_width;

        //if Schedule_Grid.RowHeights[size_row] > FGrid_Cells_Values[Size_row][psize_col].max_text_height *
        //Length(Schedule_Table.FFields) then
        //begin
        //    Schedule_Grid.RowHeights[size_row] := 20 * Length(Schedule_Table.FFields);
        //
        //end
        //else
        //if length(FGrid_Cells_Values[size_col][size_row].FRecords) > 0 then
        //    Schedule_Grid.RowHeights[size_row] :=
        //        length(FGrid_Cells_Values[size_col][size_row].FRecords) *
        //        20 * Length(Schedule_Table.FFields);

    end;

procedure TSchedule_Edit_form.FormClose(Sender: TObject; var CloseAction: TCloseAction);
    var
        i: integer;
    begin

    end;


procedure TSchedule_Edit_form.CheckGroup1ItemClick(Sender: TObject; Index: integer);
    begin
        if CheckGroup1.Checked[index] then
            Inc(Selected_fields_count)
        else
            Dec(Selected_fields_count);
        //ShowMessage(IntToStr(Selected_fields_count));
        Show_schedule();

    end;

procedure TSchedule_Edit_form.ConflictsTreeBtnClick(Sender: TObject);
    begin
        ConflictsTreeForm := TConflictsTreeForm.Create(nil);
        ConflictsModule.Refresh_conflicts();
        ConflictsTreeForm.Show;
    end;

procedure TSchedule_Edit_form.Filters_panelClick(Sender: TObject);
    begin

    end;

end.
