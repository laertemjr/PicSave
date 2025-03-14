program PicSave;

uses
  Vcl.Forms,
  uPicSave in 'uPicSave.pas' {frmPicSave},
  uGlobal in 'uGlobal.pas',
  uMultiLanguage in 'uMultiLanguage.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPicSave, frmPicSave);
  Application.Run;
end.
