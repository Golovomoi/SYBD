unit ConflictsTree;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
  ComCtrls, MetaData, ConflictsMeta, Filters, References;

type

  { TConflictsTreeForm }

  TConflictsTreeForm = class(TForm)
    TreeView: TTreeView;
    procedure FormShow(Sender: TObject);
	procedure TreeViewDblClick(Sender: TObject);
  public
    procedure BuildTree;
    procedure InsertConflicts(ANode: TTreeNode; AID:  Integer);
  end;

var
  ConflictsTreeForm: TConflictsTreeForm;

implementation

{ TConflictsTreeForm }

procedure TConflictsTreeForm.InsertConflicts(ANode: TTreeNode; AID:  Integer);
var
  i: Integer;
  Pairs: TConflictPairs;
  tmpNode: TTreeNode;
begin
  Pairs := ConflictsModule.ConflictPairs[AID];
  for i := 0 to High(Pairs) do begin
    tmpNode := TreeView.Items.AddChild(ANode, Format('Конфликт между %d и %d',
      [Pairs[i].x, Pairs[i].y]));
    tmpNode.Data := @ConflictsModule.ConflictPairs[AID][i];
  end;
end;

procedure TConflictsTreeForm.BuildTree;
var
  i: Integer;
  rootNode, currLvlNode: TTreeNode;
begin
  rootNode := TreeView.Items.Add(nil, 'Конфликты');
  //ShowMessage(inttostr(High(Conflicts)));
  for i := 0 to High(Conflicts) do begin
    currLvlNode := TreeView.Items.AddChild(rootNode,
      Format('%d. %s', [i + 1, Conflicts[i].FName]));
    InsertConflicts(currLvlNode, i);
  end;
  rootNode.Expanded := True;
end;

procedure TConflictsTreeForm.FormShow(Sender: TObject);
begin
  BuildTree;
end;

procedure TConflictsTreeForm.TreeViewDblClick(Sender: TObject);
var
  a, b: integer;
  Reference_form: TReferenceForm;
begin
  if TreeView.Selected = nil then Exit;
  with TPoint(TreeView.Selected.Data^) do begin
    a := x;
    b := y;
  end;
  Reference_form:= TReferenceForm.Create(Schedule_Table,[a,b]);
  Reference_form.Show_Table(Schedule_Table);
end;

{$R *.lfm}

end.
