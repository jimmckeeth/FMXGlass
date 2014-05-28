unit Glass.Pixelate;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls,
  FMX.Graphics, FMX.Effects, Glass, FMX.Filter.Effects;

type
  TPixelateGlass = class(TGlass)
  private
    FPixelate: TPixelateEffect;
    function GetBlockCount: Single;
    procedure SetBlockCount(const Value: Single);
  protected
    procedure ProcessChildEffect(const AParentScreenshotBitmap: TBitmap); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property BlockCount: Single read GetBlockCount write SetBlockCount nodefault;
  end;

procedure Register;

implementation

uses
  FMX.Forms, System.Math, System.Types;

{ TGlass }

constructor TPixelateGlass.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FPixelate := TPixelateEffect.Create(nil);
  FPixelate.BlockCount := 25;
end;

destructor TPixelateGlass.Destroy;
begin
  FPixelate.Free;

  inherited Destroy;
end;

function TPixelateGlass.GetBlockCount: Single;
begin
  Result := FPixelate.BlockCount;
end;

procedure TPixelateGlass.SetBlockCount(const Value: Single);
begin
  FPixelate.BlockCount := Value;
end;

procedure TPixelateGlass.ProcessChildEffect(const AParentScreenshotBitmap: TBitmap);
begin
  inherited;
  FPixelate.ProcessEffect(Canvas, AParentScreenshotBitmap, FPixelate.BlockCount);
end;

procedure Register;
begin
  RegisterComponents('Glass', [TPixelateGlass]);
end;

end.
