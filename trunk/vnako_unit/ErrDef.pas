{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
unit ErrDef;

interface

uses Windows, Graphics, BitmapUtils, BigBitmap;

type
  // 色を量子化するクラス
  TQuantizeColor = class
  public
    function GetQuantizedColor(Color: TTriple): TTriple; virtual; abstract;
  end;

function ErrorDefusion(Bitmap: TBitmap;
                       QuantizeColor: TQuantizeColor): TBitmap; overload;

function ErrorDefusion(Bitmap: TBigBitmap;
                       QuantizeColor: TQuantizeColor): TBigBitmap; overload;




implementation

type
  // 誤差拡散フィルタ用パラメータレコード
  TErrorDefusionParams = record
    QuantizeColor: TQuantizeColor;
  end;
  PErrorDefusionParams = ^TErrorDefusionParams;


// 誤差拡散フィルタ(Floyd-Steinbergフィルタ)
function ErrorDefusionFilterProc(x, y: Integer; Mat: TTripleMatrix;
                                 pData: Pointer): TTriple;
var
  pParams: PErrorDefusionParams;
  QuantizedColor: TTriple;          // 最適カラー
  RError, GError, BError: Integer;  // 最適カラーの誤差

  function LimitValue(Value: Integer): Integer;
  begin
    Result := Value;
    if Result < 0 then Result := 0;
    if Result > 255 then Result := 255;
  end;
begin
  pParams := pData;

  // 最適カラーを求める
  QuantizedColor := pParams.QuantizeColor.GetQuantizedColor(Mat[0][0]);

  // 最適カラーの誤差を求める
  RError := QuantizedColor.r   - Mat[0][0].r;
  GError := QuantizedColor.g - Mat[0][0].g;
  BError := QuantizedColor.b  - Mat[0][0].b;

  // 戻り値 := 最適カラー
  Result := QuantizedColor;

  // 誤差を拡散する(Floyd-Steinberg)
  Mat[ 0][ 1].r := LimitValue(Mat[ 0][ 1].r - RError * 7 div 16);
  Mat[ 0][ 1].g := LimitValue(Mat[ 0][ 1].g - GError * 7 div 16);
  Mat[ 0][ 1].b := LimitValue(Mat[ 0][ 1].b - BError * 7 div 16);

  Mat[ 1][-1].r := LimitValue(Mat[ 1][-1].r - RError * 3 div 16);
  Mat[ 1][-1].g := LimitValue(Mat[ 1][-1].g - GError * 3 div 16);
  Mat[ 1][-1].b := LimitValue(Mat[ 1][-1].b - BError * 3 div 16);

  Mat[ 1][ 0].r := LimitValue(Mat[ 1][ 0].r - RError * 5 div 16);
  Mat[ 1][ 0].g := LimitValue(Mat[ 1][ 0].g - GError * 5 div 16);
  Mat[ 1][ 0].b := LimitValue(Mat[ 1][ 0].b - BError * 5 div 16);

  Mat[ 1][ 1].r := LimitValue(Mat[ 1][ 1].r - RError * 1 div 16);
  Mat[ 1][ 1].g := LimitValue(Mat[ 1][ 1].g - GError * 1 div 16);
  Mat[ 1][ 1].b := LimitValue(Mat[ 1][ 1].b - BError * 1 div 16);
end;


function ErrorDefusion(Bitmap: TBitmap;
                       QuantizeColor: TQuantizeColor): TBitmap;
var
  Params: TErrorDefusionParams;
begin
  Params.QuantizeColor := QuantizeColor;
  Result := BitmapFilter(Bitmap, ErrorDefusionFilterProc,  @Params);
end;

function ErrorDefusion(Bitmap: TBigBitmap;
                       QuantizeColor: TQuantizeColor): TBigBitmap;
var
  Params: TErrorDefusionParams;
begin
  Params.QuantizeColor := QuantizeColor;
  Result := BitmapFilter(Bitmap, ErrorDefusionFilterProc,  @Params);
end;

end.

