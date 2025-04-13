unit uPicSave;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Phys.MSAccDef, FireDAC.Phys.ODBCBase, FireDAC.Phys.MSAcc,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, Vcl.ExtCtrls, Winapi.ShellAPI, Vcl.Buttons;

type
  TfrmPicSave = class(TForm)
    StatusBar1: TStatusBar;
    Label1: TLabel;
    btnBrowse: TButton;
    edtBD: TEdit;
    Label3: TLabel;
    cbbTable: TComboBox;
    Label2: TLabel;
    cbbField: TComboBox;
    OpenDialog1: TOpenDialog;
    FDConnection1: TFDConnection;
    FDPhysMSAccessDriverLink1: TFDPhysMSAccessDriverLink;
    FDTable1: TFDTable;
    btnRecover: TButton;
    Label4: TLabel;
    btnBrowse2: TButton;
    edtSaved: TEdit;
    FileOpenDialog1: TFileOpenDialog;
    ProgressBar1: TProgressBar;
    Image1: TImage;
    Label5: TLabel;
    btn_ptBR: TSpeedButton;
    btn_en: TSpeedButton;
    procedure btnBrowseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnBrowse2Click(Sender: TObject);
    procedure btnRecoverClick(Sender: TObject);
    procedure cbbTableChange(Sender: TObject);
    procedure btn_ptBRClick(Sender: TObject);
    procedure btn_enClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure clean;
    procedure checkTable;
  public
    { Public declarations }
    function GetVersionInfo(const app:string):string;
  end;

var
  frmPicSave: TfrmPicSave;
  path1, path2:string;
  sVerInfo : string;

implementation

uses
   uGlobal, uMultiLanguage;

{$R *.dfm}


procedure TfrmPicSave.FormShow(Sender: TObject);
begin
   clean;
   FileOpenDialog1.Options := [fdoPickFolders];
   path1 := EmptyStr;
   path2 := EmptyStr;
   sVerInfo := GetVersionInfo(Application.ExeName);
   ptBR;
end;

procedure TfrmPicSave.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   FDTable1.Close;
end;

procedure TfrmPicSave.clean;
begin
   edtBD.Clear;
   cbbTable.Clear;
   cbbField.clear;
   btnBrowse2.Enabled := False;
   edtSaved.Clear;
   btnRecover.Enabled := False;
   Image1.Picture := nil;
end;

procedure TfrmPicSave.btnBrowse2Click(Sender: TObject);
begin
   edtSaved.Clear;
   btnRecover.Enabled := False;

   if path2 <> EmptyStr then
      FileOpenDialog1.DefaultFolder := path2;

   FileOpenDialog1.FileName := EmptyStr;

   if FileOpenDialog1.Execute then
   begin
      edtSaved.Text := FileOpenDialog1.FileName;
      path2 := FileOpenDialog1.FileName;
      btnRecover.Enabled := True;
   end;
end;

procedure TfrmPicSave.cbbTableChange(Sender: TObject);
begin
   checkTable;
end;

procedure TfrmPicSave.checkTable;
var i:Integer;
begin
   btnBrowse2.Enabled := False;

   FDTable1.Close;
   FDTable1.TableName := cbbTable.Text;
   FDTable1.Open;
   FDTable1.Last;
   FDTable1.First;

   if FDTable1.RecordCount = 0 then
    begin
       ShowMessage(strMsg[0]); // The table is empty.
       Exit;
    end;

    try
       cbbField.Clear;
       for i:=0 to FDTable1.Fields.Count -1 do
       begin
            if FDTable1.Fields[i].DataType = ftBlob then
               cbbField.Items.Add(FDTable1.Fields[i].FieldName);
       end;
    except
       ShowMessage(strMsg[1]); // The table has field type(s) incompatible with the FireDAC standard
       Exit;
    end;

    if cbbField.GetCount = 0 then
    begin
       ShowMessage(strMsg[2]); // There are no BLOB type fields in this table.
       Exit;
    end;

   btnBrowse2.Enabled := True;

end;

procedure TfrmPicSave.btnBrowseClick(Sender: TObject);
begin
   clean;

   if path1 <> EmptyStr then
      OpenDialog1.InitialDir := path1;

   OpenDialog1.FileName := EmptyStr;

   if OpenDialog1.Execute then
   begin
      edtBD.Text := OpenDialog1.FileName;
      if ExtractFileExt(OpenDialog1.FileName) <> '.mdb' then
      begin
         ShowMessage(strMsg[3]); // It is not a MS-Access .mdb database
         clean;
         Exit;
      end;

      path1 := ExtractFilePath(OpenDialog1.FileName);

      try
         FDConnection1.Connected := False;
         FDConnection1.Params.Clear;
         FDConnection1.Params.Add('DriverID=MSAcc');
         FDConnection1.Params.Add('Database=' + edtBD.Text);
         FDConnection1.Connected := True;
         ShowMessage(strMsg[4]); // Database connected.
         FDConnection1.GetTableNames('', '', '', cbbTable.Items);
         cbbTable.ItemIndex := 0;
         cbbTable.Enabled := True;

         if cbbTable.Text = EmptyStr then
         begin
            ShowMessage(strMsg[5]); // There are no tables in the database.
            FDTable1.Close;
            clean;
            Exit;
         end
         else
            checkTable;
      except
         ShowMessage(strMsg[6]); // Unable to connect to the database.
         clean;
      end;
   end;
end;

procedure TfrmPicSave.btnRecoverClick(Sender: TObject);
var i, c, n, e :Integer;
    s, arq1, arq2 : string;
begin
   FDTable1.Last;
   FDTable1.First;
   ProgressBar1.Min := 0;
   ProgressBar1.Max := FDTable1.RecordCount -1;

   i := 0;
   c := 0;
   n := 0;
   e := 0;
   arq1 := FileOpenDialog1.FileName + '\' + cbbTable.Text + cbbField.Text;
   while not FDTable1.EOF do
   begin
      try
         if FDTable1.FieldByName(cbbField.Text).Value = null then
         begin
            Inc(n);
         end
         else
         begin
            Image1.Picture.Assign(GetImageFromBlob(TBlobField(FDTable1.FieldByName(cbbField.Text))));
            s := GraphicExtension(TGraphicClass(GetClass(Image1.Picture.Graphic.ClassName)));
            if s = EmptyStr then s := 'tif'; // POG
            arq2 := arq1 + IntToStr(c+1) + '.' + s;
            Image1.Picture.SaveToFile(arq2);
            Inc(c);
         end;
      except
         Inc(e);
      end;
      ProgressBar1.Position := i;
      Inc(i);
      FDTable1.Next;
   end;

   ShowMessage(strMsg[7] + #13#10 + #13#10 + // Task completed:
               strMsg[8] + IntToStr(n) + #13#10 + // Blank fields:
               strMsg[9] + IntToStr(e) + #13#10 + // Unrecovered fields:
               strMsg[10] + IntToStr(c)); // Recovered images:
   ProgressBar1.Position := 0;
   ShellExecute(Application.Handle, 'open', PChar(FileOpenDialog1.FileName),nil, nil, SW_SHOWDEFAULT);
   FDTable1.Close;
   clean;
end;

function TfrmPicSave.GetVersionInfo(const app: string): string;
type
  TVersionInfo = packed record
    Dummy: array[0..7] of Byte;
    V2, V1, V4, V3: Word;
  end;
var
  Zero, Size: Cardinal;
  Data: Pointer;
  VersionInfo: ^TVersionInfo;
begin
  Size := GetFileVersionInfoSize(Pointer(app), Zero);
  if Size = 0 then
    Result := ''
  else
  begin
    GetMem(Data, Size);
    try
      GetFileVersionInfo(Pointer(app), 0, Size, Data);
      VerQueryValue(Data, '\', Pointer(VersionInfo), Size);
      Result := VersionInfo.V1.ToString + '.' + VersionInfo.V2.ToString + '.' + VersionInfo.V3.ToString + '.' + VersionInfo.V4.ToString;
    finally
      FreeMem(Data);
    end;
  end;
end;

procedure TfrmPicSave.btn_enClick(Sender: TObject);
begin
   en;
end;

procedure TfrmPicSave.btn_ptBRClick(Sender: TObject);
begin
   ptBR;
end;

end.
