program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
	cthreads,
  {$ENDIF}{$ENDIF}
	Interfaces, // this includes the LCL widgetset
	Forms, MainUnit, references, bddatamodule, MetaData, Filters, CardEdit, 
	Schedule_Edit, Sch_export, ConflictsMeta, ConflictsTree
	{ you can add units after this };

{$R *.res}

begin
	RequireDerivedFormResource := True;
	Application.Initialize;
	Application.CreateForm(TMySql, My_Sql);
	Application.CreateForm(TReferenceForm, Reference_Form);
	Application.CreateForm(TBDDataModule, Data_Module);
	Application.CreateForm(TCardEditForm, CardEditForm);
	Application.CreateForm(TSchedule_Edit_form, Schedule_Edit_form);
    Application.CreateForm(TConflictsModule, ConflictsModule);
    Application.CreateForm(TConflictsTreeForm, ConflictsTreeForm);
	Application.Run;
end.

