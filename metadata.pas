unit MetaData;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, bddatamodule, Dialogs;

type

    { TField_Info }
    TField_Type = (FTStr, FTInt, FTTime, FTDays);

    TTitle_Field = record
        FName: string;
        FId: integer;
    end;

    TGrid_Record = record
        FValues: array of string;
    end;

    TGrid_Cell = record
        FRecords: array of TGrid_Record;
    end;
    TMy_Grid = array of array of TGrid_Cell;

    TTitle_Array = array of TTitle_Field;

    TField_Info = class
        Flength: integer;
        FName: string;
        FRu_Name: string;
        FField_Type: TField_Type;
        FOwner_Table_Name: string;

        constructor Create(AOwner_Table_Name, Aname, ARu_Name: string;
            AField_Type: TField_Type);
        function Get_Field_Name(): string; virtual;
        function Get_Inner_From(): string; virtual;
        function Get_Source_Table(): string; virtual;
        function Get_Inner_Field(): string; virtual;
        function Get_Order_By(): string; virtual;

    end;

    { TReference_Field_Info }

    TReference_Field_Info = class(TField_Info)
        FInner_Table_Name: string;
        FInner_Field_Name: string;
        constructor Create(AOwner_Table_Name, AName, ARu_Name: string;
            AField_Type: TField_Type; AInner_Field_Name, AInner_Table_Name: string);
        function Get_Field_Name(): string; override;
        function Get_Inner_From(): string; override;
        function Get_Source_Table(): string; override;
        function Get_Inner_Field(): string; override;
        function Get_Order_By: string; override;
    end;


    { TTable_Info }

    TTable_Info = class
    private
        FSelect, FFrom: string;
    public
        FReference_Table: boolean;
        FTable_Name, FTableRuName: string;
        FFields: array of TField_Info;
        FGenerator_Name: string;
        constructor Create(ATable_Name, ATable_Ru_Name, AGenerator_Name: string;
            AReference_Table: boolean);
        procedure Add_Field(AName, ARu_Name: string; AField_Type: TField_Type);
        procedure Add_Field(AName, ARu_Name: string; AField_Type: TField_Type;
            AInner_Field_Name, AInner_Table_Name: string);
        function Get_select(): string;
        function Get_From(): string;
        function Get_Schedule_select(): string;
    end;

const
    Count_schedule_fields = 7;

var
    My_Tables: array of TTable_Info;
    Schedule_Table: TTable_Info;

procedure Add_My_Table(ATable_Name, ATable_Ru_Name, AGenerator_Name: string;
    AReference_Table: boolean);

implementation


procedure Add_My_Table(ATable_Name, ATable_Ru_Name, AGenerator_Name: string;
    AReference_Table: boolean);
begin
    setlength(My_Tables, length(My_Tables) + 1);
    My_Tables[High(My_Tables)] :=
        TTable_Info.Create(ATable_Name, ATable_Ru_Name, AGenerator_Name, AReference_Table);
end;

{ TReference_Field_Info }

constructor TReference_Field_Info.Create(AOwner_Table_Name, AName, ARu_Name: string;
    AField_Type: TField_Type; AInner_Field_Name, AInner_Table_Name: string);
begin
    FInner_Field_Name := AInner_Field_Name;
    FInner_Table_Name := AInner_Table_Name;
    inherited Create(AOwner_Table_Name, AName, ARu_Name, AField_Type);
end;

function TReference_Field_Info.Get_Field_Name: string;
begin
    Result := ' ' + FInner_Table_Name + '.' + FInner_Field_Name + ' ';
end;

function TReference_Field_Info.Get_Inner_From: string;
begin
    Result := ' inner join ' + FInner_Table_Name + ' on ' + FOwner_Table_Name +
        '.' + FName + ' = ' + FInner_Table_Name + '.id ';
end;

function TReference_Field_Info.Get_Source_Table: string;
begin
    Result := FInner_Table_Name;
end;

function TReference_Field_Info.Get_Inner_Field: string;
begin
    Result := FInner_Field_Name;
end;

function TReference_Field_Info.Get_Order_By: string;
begin
    if FField_Type = FTDays then
        Result := ' Order by ' + FInner_Table_Name + '.Field_Index '
    else
        Result := ' Order by ' + FInner_Table_Name + '.' + FInner_Field_Name + ' ';
end;


{ TTable_Info }

constructor TTable_Info.Create(ATable_Name, ATable_Ru_Name, AGenerator_Name: string;
    AReference_Table: boolean);
var
    i: integer;
begin
    FReference_Table := AReference_Table;
    FTable_Name := ATable_Name;
    FTableRuName := ATable_Ru_Name;
    FGenerator_Name := AGenerator_Name;
end;

procedure TTable_Info.Add_Field(AName, ARu_Name: string; AField_Type: TField_Type);
begin
    SetLength(FFields, Length(FFields) + 1);
    FFields[High(FFields)] := TField_Info.Create(FTable_Name, AName, ARu_Name, AField_Type);
end;

procedure TTable_Info.Add_Field(AName, ARu_Name: string; AField_Type: TField_Type;
    AInner_Field_Name, AInner_Table_Name: string);
begin
    SetLength(FFields, Length(FFields) + 1);
    FFields[High(FFields)] := TReference_Field_Info.Create(FTable_Name,
        AName, ARu_Name, AField_Type, AInner_Field_Name, AInner_Table_Name);
end;

function TTable_Info.Get_select: string;
var
    i: integer;
begin
    Result := ' select ';
    for i := 0 to High(FFields) do
        Result += ' ' + FFields[i].Get_Field_Name() + ' ,';
    SetLength(Result, Length(Result) - 1);
end;

function TTable_Info.Get_From: string;
var
    i: integer;
begin
    Result := ' From ' + FTable_Name + ' ';
    for i := 0 to High(FFields) do
        Result += FFields[i].Get_Inner_From();
end;

function TTable_Info.Get_Schedule_select: string;
var
    i: integer;
begin
    Result := Get_select() + ' ,';
    for i := 1 to High(FFields) do
    begin
        Result += ' ' + Ffields[i].FName + ' ,';
    end;
    SetLength(Result, Length(Result) - 1);
end;



{ TField_Info }

constructor TField_Info.Create(AOwner_Table_Name, Aname, ARu_Name: string;
    AField_Type: TField_Type);
begin
    FName := Aname;
    FRu_Name := ARu_Name;
    FField_Type := AField_Type;
    FOwner_Table_Name := AOwner_Table_Name;
end;

function TField_Info.Get_Field_Name: string;
begin
    Result := FOwner_Table_Name + '.' + FName;
end;

function TField_Info.Get_Inner_From: string;
begin
    Result := '';
end;

function TField_Info.Get_Source_Table: string;
begin
    Result := FOwner_Table_Name;
end;

function TField_Info.Get_Inner_Field: string;
begin
    Result := FName;
end;

function TField_Info.Get_Order_By: string;
begin
    if FField_Type = FTDays then
        Result := ' Order by Field_Index '
    else
        Result := ' Order By ' + FName + ' ';
end;

initialization

    Add_My_Table('Groups', 'Группы', 'Groups_id', False);
    My_Tables[High(My_Tables)].Add_Field('Id', 'Ай-Ди', FTInt);
    My_Tables[High(My_Tables)].Add_Field('Group_Name', 'Имя Группы', FTStr);
    My_Tables[High(My_Tables)].Add_Field('Students', 'Количество Учащихся', FTInt);

    Add_My_Table('Disciplines', 'Предметы', 'Disciplines_Id', False);
    My_Tables[High(My_Tables)].Add_Field('Id', 'Ай-Ди', FTInt);
    My_Tables[High(My_Tables)].Add_Field('Discipline_Name', 'Название', FTStr);

    Add_My_Table('Professors', 'Преподаватели', 'Professors_Id', False);
    My_Tables[High(My_Tables)].Add_Field('Id', 'Ай-Ди', FTInt);
    My_Tables[High(My_Tables)].Add_Field('Professor_Name', 'Имя', FTStr);


    Add_My_Table('Days', 'Дни Недели', 'Days_Id', False);
    My_Tables[High(My_Tables)].Add_Field('Id', 'Ай-Ди', FTInt);
    My_Tables[High(My_Tables)].Add_Field('Day_Name', 'Наименование', FTDays);
    My_Tables[High(My_Tables)].Add_Field('Field_Index', 'Номер', FTStr);

    Add_My_Table('Times', 'Пары', 'Times_Id', False);
    My_Tables[High(My_Tables)].Add_Field('Id', 'Ай-Ди', FTInt);
    My_Tables[High(My_Tables)].Add_Field('Begining', 'Начало', FTStr);
    My_Tables[High(My_Tables)].Add_Field('Finish', 'Окончание', FTStr);
    My_Tables[High(My_Tables)].Add_Field('Field_Index', 'Номер', FTStr);

    Add_My_Table('Rooms', 'Кабинеты', 'Rooms_Id', False);
    My_Tables[High(My_Tables)].Add_Field('Id', 'Ай-Ди', FTInt);
    My_Tables[High(My_Tables)].Add_Field('Room_Name', 'Имя', FTStr);
    My_Tables[High(My_Tables)].Add_Field('People', 'Вместимость', FTInt);

    Add_My_Table('Professors_Disciplines', 'Преподаватель - Предмет',
        'Professors_Disciplines_id', True);
    My_Tables[High(My_Tables)].Add_Field('Id', 'Ай-Ди', FTInt);
    My_Tables[High(My_Tables)].Add_Field('Professor_id', 'Преподаватель',
        FTStr, 'Professor_Name', 'Professors');
    My_Tables[High(My_Tables)].Add_Field('Discipline_id', 'Предмет',
        FTSTr, 'Discipline_Name', 'Disciplines');

    Add_My_Table('Disciplines_Groups', 'Предмет - Группа', 'Disciplines_Groups_id', True);
    My_Tables[High(My_Tables)].Add_Field('Id', 'Ай-Ди', FTInt);
    My_Tables[High(My_Tables)].Add_Field('Discipline_id', 'Предмет',
        FTStr, 'Discipline_Name', 'Disciplines');
    My_Tables[High(My_Tables)].Add_Field('Group_id', 'Группа', FTStr,
        'Group_Name', 'Groups');

    Add_My_Table('Schedule_Items', 'Расписание', 'Schedule_Items_Id', True);
    My_Tables[High(My_Tables)].Add_Field('Id', 'Ай-Ди', FTInt);
    My_Tables[High(My_Tables)].Add_Field('Subject_id', 'Предмет', FTStr,
        'Discipline_Name', 'Disciplines');
    My_Tables[High(My_Tables)].Add_Field('Professor_id', 'Преподаватель',
        FTStr, 'Professor_Name', 'Professors');
    My_Tables[High(My_Tables)].Add_Field('Day_id', 'День Недели', FTDays,
        'Day_Name', 'Days');
    My_Tables[High(My_Tables)].Add_Field('Time_id', 'Время', FTStr, 'Begining', 'Times');
    My_Tables[High(My_Tables)].Add_Field('Group_id', 'Группа', FTStr,
        'Group_Name', 'Groups');
    My_Tables[High(My_Tables)].Add_Field('Room_id', 'Кабинет', FTStr, 'Room_Name', 'Rooms');

    Schedule_Table := My_Tables[High(My_Tables)];



    //Add_My_Table('Groups', 'Группы',
    //       ['id', 'Name', 'peoples'], ['Ай-Ди', 'Имя Гуппы',
    //       'Количество Учащихся'], false, [], [], [Tint, Tstr, Tint]);

    //   Add_My_Table('Disciplines', 'Предметы', ['id', 'name'],
    //       ['Ай-Ди', 'Название'], false, [], [], [Tint, Tstr]);

    //   Add_My_Table('Professors', 'Преподаватели', ['id', 'Name'],
    //       ['Ай-Ди', 'Имя'], false, [], [], [Tint, Tstr]);

    //   Add_My_Table('Days', 'Дни Недели', ['id', 'Name'],
    //       ['Ай-Ди', 'Наименование'], false, [], [], [Tint, Tstr]);

    //   Add_My_Table('Times', 'Пары', ['id', 'begining', 'finish', 'name'],
    //       ['Ай-Ди', 'Начало', 'Окончание', 'Название'],
    //       false, [], [], [Tint, Tstr, Tstr, Tstr]);

    //   Add_My_Table('Rooms', 'Кабинеты', ['id', 'name', 'peoples'],
    //       ['Ай-Ди', 'Имя', 'Вместимость'], false, [], [], [Tint, Tstr, Tint]);

    //   Add_My_Table('Professor_Discipline', 'Преподаватель - Предмет',
    //       ['Teacher', '"subject"'], ['Преподаватель', 'Предмет'],
    //       true, ['Professors', 'Disciplines'], ['Name', 'Name'], [Tstr, Tstr]);

    //   Add_My_Table('Schedule_items', 'Расписание',
    //       ['subject', 'professor', 'time_s', 'days', '"Group"', 'Room'],
    //       ['Предмет', 'Преподаватель', 'Время',
    //       'День', 'Группа', 'Кабинет'], true,
    //       ['Disciplines', 'Professors', 'times', 'days', 'groups', 'rooms'],
    //       ['name', 'name', 'name', 'name', 'name', 'name'], [Tstr, Tstr, Tstr, Tstr, Tstr, Tstr]);

end.
