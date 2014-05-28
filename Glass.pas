unit Glass;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls,
  FMX.Graphics, FMX.Effects;

type
  TGlass = class(TControl)
  private
    FParentScreenshotBitmap: TBitmap;
    FParentWidth: Single;
    FParentHeight: Single;
    FBitmapCRC: Integer;
    FCachedBitmap: TBitmap;
    FPainted: Boolean;
    procedure DefineParentSize;
    function IsBitmapSizeChanged(ABitmap: TBitmap;
      const ANewWidth, ANewHeight: Single): Boolean;
    procedure MakeParentScreenshot;
  protected
    procedure Paint; override;
    procedure ProcessChildEffect(const AParentScreenshotBitmap: TBitmap); virtual; abstract;
  public
    property Painted: Boolean read FPainted;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Position;
    property Width;
    property Height;
  end;

implementation

uses
  FMX.Forms, System.Math, System.Types, IdHashCRC, IdGlobal;

{ TOverlay }

constructor TGlass.Create(AOwner: TComponent);
begin
  inherited;

  // Create parent background
  FParentScreenshotBitmap := TBitmap.Create(0, 0);
  FCachedBitmap := TBitmap.Create(0, 0);
end;

destructor TGlass.Destroy;
begin
  FParentScreenshotBitmap.Free;
  FCachedBitmap.Free;

  inherited;
end;

procedure TGlass.DefineParentSize;
begin
  FParentWidth := 0;
  FParentHeight := 0;
  if Parent is TCustomForm then
  begin
    FParentWidth := (Parent as TCustomForm).ClientWidth;
    FParentHeight := (Parent as TCustomForm).ClientHeight;
  end;
  if Parent is TControl then
  begin
    FParentWidth := (Parent as TControl).Width;
    FParentHeight := (Parent as TControl).Height;
  end;
end;

function TGlass.IsBitmapSizeChanged(ABitmap: TBitmap;
  const ANewWidth, ANewHeight: Single): Boolean;
begin
  Result := not SameValue(ANewWidth * ABitmap.BitmapScale, ABitmap.Width) or
    not SameValue(ANewHeight * ABitmap.BitmapScale, ABitmap.Height);
end;

function IsSameBitmap(Bitmap1, Bitmap2: TBitmap): Boolean;
var
 Stream1, Stream2: TMemoryStream;
begin
  Assert((Bitmap1 <> nil) and (Bitmap2 <> nil), 'Params can''t be nil');
  Result:= False;
  if (Bitmap1.Height <> Bitmap2.Height) or (Bitmap1.Width <> Bitmap2.Width) then
     Exit;
  Stream1:= TMemoryStream.Create;
  try
    Bitmap1.SaveToStream(Stream1);
    Stream2:= TMemoryStream.Create;
    try
      Bitmap2.SaveToStream(Stream2);
      if Stream1.Size = Stream2.Size Then
        Result:= CompareMem(Stream1.Memory, Stream2.Memory, Stream1.Size);
    finally
      Stream2.Free;
    end;
  finally
    Stream1.Free;
  end;
end;

procedure TGlass.MakeParentScreenshot;
var
  Form: TCommonCustomForm;
  Child: TFmxObject;
  ParentControl: TControl;
begin
  if FParentScreenshotBitmap.Canvas.BeginScene then
    try
      FDisablePaint := True;
      if Parent is TCommonCustomForm then
      begin
        Form := Parent as TCommonCustomForm;
        for Child in Form.Children do
          if (Child is TControl) and (Child as TControl).Visible then
          begin
            if  not (Child is TGlass) or TGlass(Child).Painted then
            begin
              ParentControl := Child as TControl;
              ParentControl.PaintTo(FParentScreenshotBitmap.Canvas,
                ParentControl.ParentedRect);
            end;
          end;
      end
      else
        (Parent as TControl).PaintTo(FParentScreenshotBitmap.Canvas,
          RectF(0, 0, FParentWidth, FParentHeight));
    finally
      FDisablePaint := False;
      FParentScreenshotBitmap.Canvas.EndScene;
    end;
end;

function HashBitmap(const ABitmap: TBitmap): Integer;
var
  stream: TMemoryStream;
  hash: TIdHashCRC32;
begin
  stream := nil;
  hash := nil;
  try
    stream := TMemoryStream.Create;
    hash := TIdHashCRC32.Create;

    ABitmap.SaveToStream(stream);
    //Stream.Seek(0, soBeginning);

    Result := BytesToLongWord(hash.HashStream(stream, 0, -1));
  finally
    stream.Free;
    hash.Free;
  end;
end;

procedure TGlass.Paint;
var
  NewCRC: Integer;
begin
  inherited;

  // Make screenshot of Parent control
  DefineParentSize;
  if IsBitmapSizeChanged(FParentScreenshotBitmap, FParentWidth, FParentHeight) then
    FParentScreenshotBitmap.SetSize(Round(FParentWidth), Round(FParentHeight));
  MakeParentScreenshot;

  NewCRC := HashBitmap(FParentScreenshotBitmap);

  OutputDebugString(Pchar(IntToHex(NewCRC, 8)));

  // Apply glass effect
  Canvas.BeginScene;
  try
    if NewCRC <> FBitmapCRC then
    begin
      ProcessChildEffect(FParentScreenshotBitmap);
      FCachedBitmap.Assign(FParentScreenshotBitmap);
    end;
    Canvas.DrawBitmap(FCachedBitmap, ParentedRect, LocalRect, 1, True);
  finally
    Canvas.EndScene;
  end;
  FBitmapCRC := NewCRC;
  FPainted := True;
end;

end.
