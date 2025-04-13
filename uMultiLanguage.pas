unit uMultiLanguage;

interface

// uses

//type

   procedure ptBR();
   procedure en();
// private


// public
// end;

var
   strMsg: array[0..10] of string = ('','','','','','','','','','','');

implementation

uses
   uPicSave;

procedure ptBR();
begin
   with frmPicSave do
   begin
      Caption := 'PicSave - Recupera imagens de bancos de dados MS-Access';
      StatusBar1.Panels[0].Text := 'Desenvolvido em Delphi 12.1 - versão ' + sVerInfo + ' (2025)';
      btnBrowse.Caption := '&Procurar';
      btnBrowse2.Caption := '&Procurar';
      btnRecover.Caption := '&Recuperar';

      Label5.Caption := 'Suporta os tipos de imagem: JPEG, BMP, PNG, e TIF';
      Label1.Caption := 'Selecionar Banco de Dados MS-Access';
      Label3.Caption := 'Selecionar a tabela :';
      Label2.Caption := 'Selecionar o campo que contém as imagens a serem recuperadas :';
      Label4.Caption := 'Selecionar o local onde os arquivos recuperados serão salvos :';

      OpenDialog1.Filter := 'Bancos de Dados Microsoft Access (*.mdb)|*.mdb';
   end;

   strMsg[0]  := 'A tabela está vazia.';
   strMsg[1]  := 'A tabela possui tipo(s) de campo(s) incompatível(veis) com o padrão FireDAC';
   strMsg[2]  := 'Não existem campos do tipo BLOB nesta tabela';
   strMsg[3]  := 'Não é um banco de dados MS-Access .mdb';
   strMsg[4]  := 'Banco de dados conectado.';
   strMsg[5]  := 'Não há tabelas no banco de dados.';
   strMsg[6]  := 'Não foi possível a conexão ao banco de dados.';
   strMsg[7]  := 'Tarefa concluída : ';
   strMsg[8]  := 'Campos em branco : ';
   strMsg[9]  := 'Campos não recuperados : ';
   strMsg[10] := 'Imagens recuperadas : ';
end;

procedure en();
begin
   with frmPicSave do
   begin
      Caption := 'PicSave - Recovers images from MS-Access databases';
      StatusBar1.Panels[0].Text := 'Developed in Delphi 12.1 - version ' + sVerInfo + ' (2025)';
      btnBrowse.Caption := '&Browse';
      btnBrowse2.Caption := '&Browse';
      btnRecover.Caption := '&Recover';

      Label5.Caption := 'Supports image types: JPEG, BMP, PNG, and TIF';
      Label1.Caption := 'Select MS-Access Database';
      Label3.Caption := 'Select table:';
      Label2.Caption := 'Select the field containing the images to be recovered:';
      Label4.Caption := 'Select the location where the recovered files will be saved:';

      OpenDialog1.Filter := 'Microsoft Access databases (*.mdb)|*.mdb';
   end;

   strMsg[0]  := 'The table is empty.';
   strMsg[1]  := 'The table has field type(s) incompatible with the FireDAC standard';
   strMsg[2]  := 'There are no BLOB type fields in this table';
   strMsg[3]  := 'It is not a MS-Access .mdb database';
   strMsg[4]  := 'Database connected.';
   strMsg[5]  := 'There are no tables in the database.';
   strMsg[6]  := 'Unable to connect to the database.';
   strMsg[7]  := 'Task completed: ';
   strMsg[8]  := 'Blank fields: ';
   strMsg[9]  := 'Unrecovered fields: ';
   strMsg[10] := 'Recovered images: ';
end;

end.
