unit uGlobal;

interface

uses
   Vcl.Graphics, Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, Vcl.Imaging.GIFImg, Data.DB;

function GetImageFromBlob(const ABlobField: TBlobField): TGraphic;


implementation

uses
  System.Classes, System.SysUtils;

// Code from: https://stackoverflow.com/questions/39188245/how-to-display-picturejpg-with-tdbimage-from-tblobfield


function GetImageFromBlob(const ABlobField: TBlobField): TGraphic;
CONST
  JPG_HEADER: array [0 .. 2] of byte = ($FF, $D8, $FF);
  //GIF_HEADER: array [0 .. 2] of byte = ($47, $49, $46);
  BMP_HEADER: array [0 .. 1] of byte = ($42, $4D);
  PNG_HEADER: array [0 .. 3] of byte = ($89, $50, $4E, $47);
  TIF_HEADER: array [0 .. 2] of byte = ($49, $49, $2A);
  TIF_HEADER2: array [0 .. 2] of byte = (77, 77, 00);
  //PCX_HEADER: array [0 .. 2] of byte = (10, 5, 1);

var
  _HeaderStream: TMemoryStream;
  _ImgStream: TMemoryStream;
  _GraphicClassName: string;
  _GraphicClass: TGraphicClass;
begin
  Result := nil;

  _HeaderStream := TMemoryStream.Create;
  _ImgStream := TMemoryStream.Create;
  try
    ABlobField.SaveToStream(_ImgStream);
    _ImgStream.Position := 0;
    _HeaderStream.CopyFrom(_ImgStream, 5);
    if _HeaderStream.Size > 4 then
    begin
      if CompareMem(_HeaderStream.Memory, @JPG_HEADER, SizeOf(JPG_HEADER)) then
        _GraphicClassName := 'TJPEGImage'
      {else if CompareMem(_HeaderStream.Memory, @GIF_HEADER, SizeOf(GIF_HEADER))
      then
        _GraphicClassName := 'TGIFImage'}
      else if CompareMem(_HeaderStream.Memory, @PNG_HEADER, SizeOf(PNG_HEADER))
      then
        _GraphicClassName := 'TPNGImage'
      else if CompareMem(_HeaderStream.Memory, @BMP_HEADER, SizeOf(BMP_HEADER))
      then
        _GraphicClassName := 'TBitmap'
      else if CompareMem(_HeaderStream.Memory, @TIF_HEADER, SizeOf(TIF_HEADER))
      then
        _GraphicClassName := 'TWICImage'
      else if CompareMem(_HeaderStream.Memory, @TIF_HEADER2, SizeOf(TIF_HEADER2))
      then
        _GraphicClassName := 'TWICImage'
      {else if CompareMem(_HeaderStream.Memory, @PCX_HEADER, SizeOf(PCX_HEADER))
      then
        _GraphicClassName := 'PCXImage'};

      RegisterClasses([TIcon, TMetafile, TBitmap, TJPEGImage, TPngImage,
        TWICImage]);
      _GraphicClass := TGraphicClass(FindClass(_GraphicClassName));
      if (_GraphicClass <> nil) then
      begin
        Result := _GraphicClass.Create; // Create appropriate graphic class
        _ImgStream.Position := 0;
        Result.LoadFromStream(_ImgStream);
      end;
    end;
  finally
    FreeAndNil(_ImgStream);
    FreeAndNil(_HeaderStream);
  end;
end;

end.
