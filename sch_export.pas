unit Sch_export;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, metadata, Dialogs, ExtCtrls, comobj;

type

    TFieldsValues = array [0..Count_Schedule_Fields - 1] of string;
    TMyGridItem = array of TFieldsValues;

    TGridElem = record
        GridItem: TMyGridItem;
        Rect: boolean;
    end;

    TMyGrid = array of array of TGridElem;

procedure SaveHTML(FileName: string; AGrid: TMy_Grid;
    HorArr, VertArr: TTitle_Array; ACheckGroup: TCheckGroup);
procedure SaveExcel(FileName: string; AGrid: TMy_Grid;
    HorArr, VertArr: TTitle_Array; ACheckGroup: TCheckGroup);

implementation

procedure SaveExcel(FileName: string; AGrid: TMy_Grid;
    HorArr, VertArr: TTitle_Array; ACheckGroup: TCheckGroup);
var
    ExcelApp, ExcelSheet, ExcelCol, ExcelRow: variant;
    Size: byte;
    i, j, k, l: integer;
begin
    ExcelApp := CreateOleObject('Excel.Application');
    SaveHTML('C:\Users\Igor\Desktop\q.html', AGrid, HorArr, VertArr, ACheckGroup);
    ExcelApp.WorkBooks.Open(WideString(UTF8Decode('C:\Users\Igor\Desktop\q.html')));
    ExcelApp.WorkBooks[1].SaveAs(WideString(UTF8Decode(FileName)), $00000027);
    ExcelApp.WorkBooks[1].Save;
    ExcelApp.Quit;

    DeleteFile(UTF8Decode('C:\Users\Igor\Desktop\q.html'));

end;

procedure SaveHTML(FileName: string; AGrid: TMy_Grid; HorArr, VertArr: TTitle_Array;
    ACheckGroup: TCheckGroup);
var
    i, j, k, l: integer;
    Str: string;
begin
    AssignFile(Output, Utf8ToAnsi(FileName));
    Assign(Input, 'Head.txt');
    Reset(Input);
    Rewrite(Output);
    while not EOF do
    begin
        Readln(Str);
        WriteLn(Str);
    end;

    for i := 1 to High(HorArr) do
        WriteLn(Format('<td class = "h">%s</td>', [HorArr[i].FName]));

    for i := 1 to High(VertArr) do
    begin
        WriteLn('<tr valign = "top">');
        WriteLn(Format('<td class = "h">%s</td>', [VertArr[i].FName]));
        for j := 1 to High(HorArr) do
        begin
            WriteLn('<td>');
            for k := 0 to High(AGrid[i][j].FRecords) do
            begin
                for l := 0 to Count_Schedule_Fields - 1 do
                    if (ACheckGroup.Checked[l]) and (ACheckGroup.CheckEnabled[l]) then
                        WriteLn(Format('<b>%s:</b> %s<br />', [Schedule_Table.FFields[l].FRu_Name,
                            AGrid[i][j].FRecords[k].FValues[l]]));
                WriteLn('<div class = "separator">&nbsp;</div>');
            end;
            WriteLn('&nbsp;</td>');
        end;
    end;
    Close(Output);
    Close(Input);
end;

end.






        
