unit Glass.Blur;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls,
  FMX.Graphics, FMX.Effects, Glass;

type
  TBlurGlass = class(TGlass)
  private
    FBlur: TBlurEffect;
    function GetSoftness: Single;
    procedure SetSoftness(Value: Single);
  protected
    procedure ProcessChildEffect(const AParentScreenshotBitmap: TBitmap); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Softness: Single read GetSoftness write SetSoftness;
  end;

procedure Register;

implementation

uses
  FMX.Forms, System.Math, System.Types;

{ TGlass }

constructor TBlurGlass.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  // Create blur
  FBlur := TBlurEffect.Create(nil);
  FBlur.Softness := 0.5;
end;

destructor TBlurGlass.Destroy;
begin
  FBlur.Free;
  inherited Destroy;
end;

function TBlurGlass.GetSoftness: Single;
begin
  Result := FBlur.Softness;
end;

procedure TBlurGlass.SetSoftness(Value: Single);
begin
  FBlur.Softness := Value;
end;

procedure TBlurGlass.ProcessChildEffect(const AParentScreenshotBitmap: TBitmap);
begin
  inherited;
  FBlur.ProcessEffect(Canvas, AParentScreenshotBitmap, FBlur.Softness);
end;

procedure Register;
begin
  RegisterComponents('Glass', [TBlurGlass]);
end;

end.
