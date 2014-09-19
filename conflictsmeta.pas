unit ConflictsMeta;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, FileUtil, MetaData, bddatamodule, Dialogs;

type

    TConflictPairs = array of TPoint;

    TConflict = class
        FName: string;
        FEqual, FUnequal: array of integer;
        constructor Create(AName: string; AEqual, AUnequal: array of integer);
    end;

    { TConflictsModule }

    TConflictsModule = class(TDataModule)
        ConflictsSQLQuery: TSQLQuery;
    public
        ConflictPairs: array of TConflictPairs;
        procedure AddConflict(AName: string; AEqual, AUnequal: array of integer);
        function MakeQuery(AID: integer): string;
        function GetConflictPairs(AID: integer): TConflictPairs;
        function IsInConflict(AID: integer): TPoint;
        procedure Refresh_conflicts();
    end;

var
    ConflictsModule: TConflictsModule;
    Conflicts: array of TConflict;

implementation

constructor TConflict.Create(AName: string; AEqual, AUnequal: array of integer);
var
    i: integer;
begin
    FName := AName;
    SetLength(FEqual, Length(AEqual));
    SetLength(FUnequal, Length(AUnequal));
    for i := 0 to High(AEqual) do
        FEqual[i] := AEqual[i];
    for i := 0 to High(AUnequal) do
        FUnequal[i] := AUnequal[i];
end;

procedure TConflictsModule.AddConflict(AName: string;
    AEqual, AUnequal: array of integer);
var
    i: integer;
begin
    SetLength(Conflicts, Length(Conflicts) + 1);
    Conflicts[High(Conflicts)] := TConflict.Create(AName, AEqual, AUnequal);
    SetLength(ConflictPairs, Length(ConflictPairs) + 1);
    ConflictPairs[High(ConflictPairs)] := GetConflictPairs(High(Conflicts));
end;

function TConflictsModule.MakeQuery(AID: integer): string;
var
    i: integer;
    q, pairs: string;
    currConf: TConflict;
begin
    currConf := Conflicts[AID];
    q := 'SELECT A.*, B.* FROM Schedule_Items A INNER JOIN Schedule_Items B ON ';
    pairs := '';

    for i := 0 to High(currConf.FEqual) do
        with Schedule_Table.FFields[currConf.FEqual[i]] do
            pairs += Format('AND A.%s = B.%s ', [FName, FName]);
    for i := 0 to High(currConf.FUnequal) do
        with Schedule_Table.FFields[currConf.FUnequal[i]] do
            pairs += Format('AND A.%s <> B.%s ', [FName, FName]);
    Delete(pairs, 1, 4);
    pairs += 'AND A.ID < B.ID';
    q += pairs;
    Result := q;
end;

function TConflictsModule.GetConflictPairs(AID: integer): TConflictPairs;
var
    tmpPairs: TConflictPairs;
begin
    with ConflictsSQLQuery do
    begin
        Close;
        SQL.Clear;
        SQL.Text := MakeQuery(AID);
        Open;
        First;
        while not EOF do
        begin
            SetLength(tmpPairs, Length(tmpPairs) + 1);
            tmpPairs[High(tmpPairs)].x := Fields[0].AsInteger;
            tmpPairs[High(tmpPairs)].y := Fields[Length(Schedule_Table.FFields)].AsInteger;
            Next;
        end;
    end;
    Result := tmpPairs;
end;

function TConflictsModule.IsInConflict(AID: integer): TPoint;
var
    i, j: integer;
begin
    for i := 0 to High(Conflicts) do
        for j := 0 to High(ConflictPairs[i]) do
            if (ConflictPairs[i][j].x = AID) or (ConflictPairs[i][j].y = AID) then
                Exit(Point(i, j));
    Exit(Point(-1, -1));
end;

procedure TConflictsModule.Refresh_conflicts;
var
    i: integer;
begin
    for i := 0 to High(Conflicts) do
        Conflicts[i].Destroy;
    SetLength(Conflicts,0);
    SetLength(ConflictPairs,0);
    AddConflict('Преподаватель в разных аудиториях', [2, 4, 3], [6]);
    AddConflict('Разные пары в одной аудитории', [4, 3, 6], [2]);
    AddConflict('Группа в разных аудиториях', [4, 3, 5], [6]);
    AddConflict('Группа на разных дициплинах', [4, 3, 5], [1]);
    AddConflict('Преподаватель на разных дисциплинах', [2, 4, 3], [1]);
    AddConflict('Дублирующися пары', [1, 2, 3, 4, 5, 6], []);
end;

{$R *.lfm}end.
