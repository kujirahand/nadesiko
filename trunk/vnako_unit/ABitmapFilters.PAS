// AlphaBitmapLight FIlters for Delphi3- or C++Builder3-
// Copyright(C)'2000- buin2gou(buin2gou@jcom.home.ne.jp)
//
// このコンポーネントは自由に使用してもらって構いません
// 転載・改変も自由です。市販ソフトに使用してもロイヤリティ
// の請求は絶対にありえません。使用許可も必要ありません。
// TABitmapから、フィルタ・変形処理を持ってきたものです。
// TAbitmapの軽量化、高速化のために行っております。
//
// 一部の関数は中尾さんによってインラインアセンブラ化されています。
//
// 参考・勝手に引用ホームページ
//
// http://www.ngy.1st.ne.jp/~kengo/
// http://www2s.biglobe.ne.jp/~aks-lab/
// http://hp.vector.co.jp/authors/VA012950/aa/
// http://homepage1.nifty.com/beny/
//
// Version 2002.02.19
// 無駄な（だと思われている）関数を削除しています。
//


{$HINTS OFF}
unit ABitmapFilters;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids,ABitmap,math;

type
  PRGB24 = ^TRGB24;
  TRGB24 = packed record
    B: Byte;
    G: Byte;
    R: Byte;
  end;



  //キャッシュ用
  TCacheLines = array[0..MaxInt div SizeOf(Pointer) -1]of Pointer;
  PCacheLines = ^TCacheLines;

  TLine24 = array[0..MaxInt div SizeOf(TRGB24) -1]of TRGB24;
  PLine24 = ^TLine24;

    //色の変化処理
    procedure MonoYUV(BMP:TBitmap);
    procedure Mono(Power:Integer;BMP:TBitmap);
    procedure MonoAllAdd(BMP:TBitmap);
    procedure SuperMono(Power:Integer;BMP:TBitmap);
    procedure MaxCol(BMP:TBitmap);
    procedure Contrast(Power:Integer;BMP:TBitmap);
    procedure ColorRevision(R1,G1,B1:Integer;BMP:TBitmap);
    procedure DelCol2(dr,dg,db:Integer;BMP:TBitmap);//色削除
    procedure Nega(BMP:TBitmap);
    procedure Nega32(x,y,w,h:Integer;BMP:TBitmap);
    procedure Bright(BMP:TBitmap;iPower:SmallInt);


    //フィルタ処理(BMPに行う(自分には行わない)）
    procedure edge(BMP:TBitmap);
    procedure BiLe2(Power:Integer;BMP:TBitmap);
    procedure AllAdd2(BMP:TBitmap);
    procedure MedianFilter(BMP:TBitmap;iPower:Integer);
    procedure Gamma(bPlusMinus:Boolean;BMP:TBitmap);
    procedure CustomFilter(BMP:TBitmap;bCol:Boolean;Ra,Ga,Ba:BYTE;StrGrid:TStringGrid;iPower:Integer);
    procedure Noise(BMP:TBitmap;iEffect:Byte);
    procedure NoiseRGBALL(BMP:TBitmap;iEffect:Byte);
    procedure Laplacian(Power:Integer;BMP:TBitmap);
    procedure RGBDivide(BMP:TBitmap);
    procedure emboss(BMP:TBitmap;iPower,iBass:Byte);
    procedure thinRGB(BMP:TBitmap;iPower:Byte);
    procedure SepiaSuper(Bitmap: TBitmap;r,g,b:Byte);
    procedure Diffusion(BMP:TBitmap;iPower:Byte);
    procedure MonoNTSCave(BMP:TBitmap);
    procedure xDivide(BMP:TBitmap;iPower:Integer);
    procedure LinePic(BMP:TBitmap);
    procedure Solarization(Bitmap: TBitmap);
    procedure Gamma2(Bitmap: TBitmap; Value: Double);
    procedure Vivid(BMP:TBitmap;iPower:Byte);

    //変形
    procedure Rotate(srcBmp:TBitmap; degree:Integer);
    procedure RotateFast(srcBmp:TBitmap; degree:Integer);
    procedure ChangeTopBottom(BMP:TBitmap);
    procedure Spin(Rad:Integer;BMP:TBitmap);
    procedure Mirror(BMP:TBitmap);

    //モザイク処理
    procedure BMP8x8Moz(BMP:TBitmap;AX,AY,BX,BY:Integer;bTate:Boolean);
    procedure BMPWinMoz(BMP:TBitmap;AX,AY,BX,BY:Integer);
    procedure BMPFLMoz(BMP3:TBitmap;AX,AY,BX,BY:Integer);
    procedure BMPColorMoz(BMP3:TBitmap;AX,AY,BX,BY:Integer);
    procedure BMPRainBowMoz(BMP3:TBitmap;AX,AY,BX,BY,iDot:Integer);

    //特殊用途用
    procedure XorBitmap(BMP:TBitmap;XORPass:String);
    procedure Mozaic(Bitmap: TBitmap; WSize, HSize: Integer; Clip: TRect);

    //ヒストグラム生成
    function  History(iNo:Integer;BMP:TBitmap;var hislist:TStrings):Integer;

    //アスペクト比＆指定サイズに収まるように変形
    procedure BMPAutoSizeChange(w2,h2:Integer;BMP:TBitmap);
    procedure BMPAutoSizeChangeBlack(w2,h2:Integer;BMP:TBitmap);
    procedure BMPAutoSizeChangeOut(w2,h2:Integer;BMP,BMP3:TBitmap);
    procedure BMPSizeChangeAspect(w2,h2:Integer;BMP:TBitmap);
    procedure x2BMP(BMP:TBitmap);

    //計算処理
    function  UnOpeXY32s(iNo,h,p:Integer):TPoint;
    function  UnOpeXY32(iNo,w,p:Integer):TPoint;

    //キャッシュ用（http://homepage1.nifty.com/beny/tips/dib02.html
    function GetCacheLines(Source: TBitmap): PCacheLines;

    //マスク作成
    procedure MakeMask(ChrBMP,MaskBMP:TBitmap;Col:TColor);

    //ドロー系関数
    procedure Gradation(BMP:TBitmap;AColor,BColor:TColor;isVertical:Boolean);

    //一定比率から画面を取得
    procedure GetBMP128(iNo,p:Integer;InBMP,OutBMP2:TBitmap);
    procedure GetBMP128s(iNo,p:Integer;InBMP,OutBMP2:TBitmap);

    //その他の関数
    function  RoundByte(data:Integer):Byte;
    procedure ColToRGB(Color:TColor;var R,G,B:BYTE);

        //正・偽アンチエイリアスフォント描画
    procedure SuperTextOut(Canvas:TCanvas;X,Y:Integer;bFont:TFont;Msg:String);
    procedure SuperTextOut2(Canvas:TCanvas;X,Y,W,H:Integer;bFont:TFont;Msg:String; PDxArray: Pointer ;Options: Integer);
    procedure SuperTextOut_fly(Canvas:TCanvas; X,Y:Integer; bFont:TFont; Msg:String);
    procedure StdTextOutFast(iNo,x,y:Integer;text:String;bFOnt:TFont;Col:TColor;Canvas:TCanvas);
    procedure StdTextOut(iNo,x,y:Integer;text:String;bFOnt:TFont;Col:TColor;Canvas:TCanvas);
    procedure StdTextOut_Fly(iNo,x,y:Integer;text:String;bFOnt:TFont;Col:TColor;Canvas:TCanvas);
    procedure SuperTextOutAlpha(Canvas:TCanvas;X,Y:Integer;bFont:TFont;Msg:String;iAlpha:Byte);
    procedure SuperTextOutAlpha_fly(Canvas:TCanvas; X,Y:Integer; bFont:TFont; Msg:String;iA:Byte);

    //３２ビットアルファ付き画像を生成。RGBA形式。ARGBじゃないよ。
    procedure Convert24Ato32(BMP24,ABMP,out32BMP:TBitmap);
    procedure Convert24Ato8(in24BMP,out8BMP:TBitmap);




implementation

{$R-}

procedure MakeMask(ChrBMP,MaskBMP:TBitmap;Col:TColor);
begin

  ChrBMP.PixelFormat:=pf24bit;
  
  MaskBMP.Assign(ChrBMP);
  MaskBMP.Mask(Col);

  BitBlt(ChrBMP.Canvas.Handle,0,0,ChrBMP.Width,ChrBMP.Height,MaskBMP.Canvas.Handle,0,0,SRCPAINT);

  Nega(MaskBMP);


end;

//フィルタ等

procedure Mono(Power:Integer;BMP:TBitmap);
var
  x,y,i        :SmallInt;  //ビットマップのＸ軸、Ｙ軸
  PBit         :PByteArray;
  a,max        :Integer;
begin

  max:=Power;

  BMP.PixelFormat := pf32Bit;





  for y := 0 to BMP.Height-1 do begin
    pBit:=BMP.ScanLine[y];
    i:=0;
    for x := 0 to BMP.Width-1 do begin

      If (pBit[i]+pBit[i+1]+pBit[i+2])<max then a:=0
      else a:=255;

      pBit[i]:=a;
      inc(i);
      pBit[i]:=a;
      inc(i);
      pBit[i]:=a;
      inc(i,2);

    end;
  end;
end;

procedure SuperMono(Power:Integer;BMP:TBitmap);
var
  x,y,i        :SmallInt;  //ビットマップのＸ軸、Ｙ軸
  PBit         :PByteArray;
  a            :Integer;
begin



  BMP.PixelFormat := pf32Bit;


  //ＲＧＢモノ変換
  for y := 0 to BMP.Height-1 do begin

    pBit:=BMP.ScanLine[y];
    i:=0;
    for x := 0 to BMP.Width-1 do begin

      If pBit[i]<Power then a:=0
      else a:=255;
      pBit[i]:=a;

      inc(i);
      If pBit[i]<Power then a:=0
      else a:=255;
      pBit[i]:=a;

      inc(i);
      If pBit[i]<Power then a:=0
      else a:=255;
      pBit[i]:=a;

      inc(i,2);
    end;
  end;
end;

procedure MaxCol(BMP:TBitmap);
var
  x,y,i        :SmallInt;  //ビットマップのＸ軸、Ｙ軸
  R,G,B        :Byte;      //Ｒ値、Ｇ値、Ｂ値
  PBit         :PByteArray;
begin


  BMP.PixelFormat := pf32Bit;


  //最大値出力
  for y := 0 to BMP.Height-1 do
  begin

    pBit:=BMP.ScanLine[y];
    i:=0;
    for x := 0 to BMP.Width-1 do
    begin

      r:=pBit[i];
      g:=pBit[i+1];
      b:=pBit[i+2];

      If (R>=G) and (R>=B) then begin
         G:=0;
         B:=0;
      end else if (G>=R) and (G>=B) then begin
         R:=0;
         B:=0;
      end else if (B>=R) and (B>=G) then begin
         R:=0;
         G:=0;
      end;

      pBit[i]:=r;
      inc(i);
      pBit[i]:=g;
      inc(i);
      pBit[i]:=b;
      inc(i,2);
    end;
  end;
end;

procedure ColorRevision(R1,G1,B1:Integer;BMP:TBitmap);
var
  x,y,i:Integer;  //ビットマップのＸ軸、Ｙ軸
  pBit :pByteArray;
begin
   BMP.PixelFormat := pf32bit;

   //色補正処理
   for y := 0 to BMP.Height-1 do begin
       pBit:=BMP.ScanLine[y];
       i:=0;
       for x := 0 to BMP.Width-1 do begin
           pBit[i]:=RoundByte(pBit[i]+b1);
           inc(i);

           pBit[i]:=RoundByte(pBit[i]+g1);
           inc(i);

           pBit[i]:=RoundByte(pBit[i]+r1);
           inc(i,2);
       end;
    end;
end;

procedure edge(BMP:TBitmap);
var
  x,y,i,j,x2,y2:SmallInt;  //ビットマップのＸ軸、Ｙ軸
  R,G,B      :Integer;      //Ｒ値、Ｇ値、Ｂ値
  PBit,PBit2 :PByteArray;
  R2,G2,B2,k1:Integer;
  BMP2       :TBitmap;
begin

 BMP2:=TBitmap.Create;

 try
  BMP2.Width :=BMP.WIdth;
  BMP2.Height:=BMP.Height;


  BMP2.PixelFormat:=pf24Bit;
  BMP.PixelFormat :=pf24Bit;

  //エッジ処理
  for y := 1 to BMP2.Height-3 do begin

    pBit:=BMP2.ScanLine[y];
    j:=0;
    for x := 1 to BMP2.Width-3 do begin
       r2:=0;
       g2:=0;
       b2:=0;

       k1:=(x-1)*3;

       for y2:=-1 to 1 do begin
           PBit2:=BMP.ScanLine[y+y2];
           i:=k1;
           for x2:=-1 to 1 do begin
               //読み込み
               r2:=r2+PBit2[i];
               inc(i);
               g2:=g2+PBit2[i];
               inc(i);
               b2:=b2+PBit2[i];
               inc(i);
           end;
       end;


       //平均値を出す

      r:=PBit2[j];
      r:=RoundByte(r2-r*9);
      pBit[j]:=r;
      inc(j);

      g:=PBit2[j];
      g:=RoundByte(g2-g*9);
      pBit[j]:=g;
      inc(j);

      b:=PBit2[j];
      b:=RoundByte(b2-b*9);
      pBit[j]:=b;
      inc(j);

    end;
  end;

  BMP.Assign(BMP2);
 finally
  //開放
  BMP2.Free;
 end;

end;

procedure emboss(BMP:TBitmap;iPower,iBass:Byte);
var
  x,y,i     :SmallInt;  //ビットマップのＸ軸、Ｙ軸
  PBit,PBit2,PBit3:PByteArray;
  ew  :Integer;
  BMP2      :TBitmap;
begin

 BMP2:=TBitmap.Create;

 try
  BMP2.Width :=BMP.WIdth;
  BMP2.Height:=BMP.Height;


  BMP2.PixelFormat:=pf24Bit;
  BMP.PixelFormat :=pf24Bit;

  ew:=(BMP2.Width-2)*3;

  //エッジ処理
  for y:=1 to BMP2.Height-2 do begin
    pBit:=BMP2.ScanLine[y];
    PBit2:=BMP.ScanLine[y-1];
    PBit3:=BMP.ScanLine[y+1];

    i:=0;

    for x := 1 to ew do begin
        pBit[i]:=RoundByte((pBit2[i]-pBit3[i])*iPower+iBass);
        inc(i);
    end;
  end;

  BMP.Assign(BMP2);
 finally
  //開放
  BMP2.Free;
 end;

end;



procedure Contrast(Power:Integer;BMP:TBitmap);
var
  x,y,i,W,h           :SmallInt;
  ContrastRevision,CR:Double;
  PBit            :PByteArray;
begin

  //コントラスト補正値を設定
  ContrastRevision :=(Power / 100);

  //CR:=127.5*ContrastRevision;


  BMP.PixelFormat:=pf32Bit;
  W:=(BMP.Width-1)*4;
  h:=BMP.Height-1;
  //コントラスト強調処理
  for y := 0 to h do begin

    pBit:=BMP.ScanLine[y];
    i:=0;
    for x := 0 to w do begin

      pBit[i]:=RoundByte(Round(pBit[i]+ContrastRevision*(pBit[i]-127.5)));
      //pBit[i]:=RoundByte(Round(pBit[i]*ContrastRevision-CR));
      inc(i);

      // A+B(A-C)
      // A(B+1)-BC

    end;
  end;
end;

procedure DelCol2(dr,dg,db:Integer;BMP:TBitmap);
var
  x,y,i        :SmallInt;  //ビットマップのＸ軸、Ｙ軸
  PBit         :PByteArray;
begin

  BMP.PixelFormat := pf24Bit;

  //色削除処理
  for y := 0 to BMP.Height-1 do
  begin

    pBit:=BMP.ScanLine[y];
    i:=0;
    for x := 0 to BMP.Width-1 do
    begin

      pBit[i]:=pBit[i]*dr;
      inc(i);
      pBit[i]:=pBit[i]*dg;
      inc(i);
      pBit[i]:=pBit[i]*db;
      inc(i);

    end;
  end;
end;

procedure BiLe2(Power:Integer;BMP:TBitmap);
var
  x,y,i,j,k,m,l:SmallInt;  //ビットマップのＸ軸、Ｙ軸
  R,G,B     :Integer;      //Ｒ値、Ｇ値、Ｂ値
  PBit,PBit2:PByteArray;
  W,H,x2,y2 :Integer;
  k1,k2,W2,k3     :Integer;
  SrcLine   :array of Pointer;
begin

  //色々実験

  BMP.PixelFormat := pf24Bit;
  H:=BMP.Height-1;
  W:=BMP.Width-1;
  W2:=W*3;

  SetLength(SrcLine,BMP.Height);
  for y:=0 to BMP.Height-1 do begin
      SrcLine[y]:=BMP.ScanLine[y];
  end;

  k3:=-Power*3;
  //コントラスト強調処理
  for y := 0 to H do begin

    pBit:=SrcLine[y];
    k:=0;

    k2:=k3;


    for x := 0 to W do begin

       //初期化
       r:=0;
       g:=0;
       b:=0;

       m:=0;

       k1:=k2;
       inc(k2,3);


       //ＲＧＢデータ取得
       for y2:=-Power to Power do begin
           j:=y+y2;
           If j>H then break;


           If (j>=0) then begin
              PBit2:=SrcLine[j];

              i:=k1;

              for x2:=-Power to Power do begin
                  If i>W2 then break;

                  If (i>=0) then begin
                     //読み込み

                     inc(r,PBit2[i]);
                     inc(i);
                     inc(g,PBit2[i]);
                     inc(i);
                     inc(b,PBit2[i]);
                     inc(i);

                     //割り算用
                     inc(m);
                  end else begin
                     inc(i,3);
                  end;

               end;
           end;

       end;

      //書き込み
      pBit[k]:=Byte(R div m);
      inc(k);
      pBit[k]:=Byte(G div m);
      inc(k);
      pBit[k]:=Byte(B div m);
      inc(k);
    end;
  end;

end;


//このルーチンは私が作ったわけではありません。
//かなり高速化してます。
//ＮＯＴ自作
procedure Spin(Rad:Integer;BMP:TBitmap);
var
  x,y,i,x2,y2,x2a:SmallInt;  //ビットマップのＸ軸、Ｙ軸
  PBit,pBit2       :PByteArray;
  pBMP       :TBitmap;
  iDo        :Real;
  W2,H2:Integer;
  rCos,rSin  :Int64;
  SrcLine,DestLine:array of Pointer;


begin
 {$RANGECHECKS OFF}
 pBMP:=TBitmap.Create;

 try
  iDo:=Pi/(360/Rad);
  pBMP.Width :=BMP.Width;
  pBMP.Height:=BMP.Height;

  BMP.PixelFormat :=pf32Bit;
  pBMP.PixelFormat:=pf32Bit;

  //先に計算しておかないと遅くなる
  W2:=BMP.Width  shr 1;
  H2:=BMP.Height shr 1;
  rCos:=Round(cos(iDo)*1024);
  rSin:=Round(sin(iDo)*1024);

  SetLength(SrcLine,BMP.Height);
  SetLength(DestLine,pBMP.Height);

  for y:=0 to BMP.Height-1 do begin
      SrcLine[y] :=BMP.ScanLine[y];
      DestLine[y]:=pBMP.ScanLine[y];
  end;

  for y:=0 to BMP.Height-1 do begin

    pBit:=SrcLine[y];
    i:=0;
    for x:=0 to BMP.Width-1 do begin

      x2:=((x-W2)*rcos-(y-H2)*rsin) shr 10+W2;
      If (x2>=0) and (x2<BMP.Width) then begin
         y2:=((x-W2)*rsin-(y-H2)*rcos) shr 10+H2;
         If (y2>=0) and (y2<BMP.Height) then begin

            pBit2:=DestLine[y2];
            x2a:=x2*4;
            pBit2[x2a]:=pBit[i];
            inc(x2a);
            pBit2[x2a]:=pBit[i+1];
            inc(x2a);
            pBit2[x2a]:=pBit[i+2];


         end;
      end;

      inc(i,4);
    end;
  end;
 finally
  BMP.Assign(pBMP);
  pBMP.Free;
 end;
 {$RANGECHECKS ON}
end;





//このルーチンは私が作ったわけではありませんが、
//高速化したのは私です（汗
procedure MedianFilter(BMP:TBitmap;iPower:Integer);
type
  tRGB = Record
    R : Byte;
    G : Byte;
    B : Byte
  end;
  TDataArray = Array[-1..1,-1..1] of tRGB;
var
  x,y,i     : SmallInt;  //ビットマップのＸ軸、Ｙ軸
  fx,fy     : SmallInt;  //フィルタマスク
  pxlRGB    : TDataArray;
  Median    : LongInt; //抽出値
  Point     : Byte;    //抽出値設定
  FilterBMP : TBitMap;   //フィルタビットマップ
  PBit,PBit2: PByteArray;

  //ソート関数
Function Sort(Data : TDataArray; Point:Byte):Longint;
var
  x,y   : SmallInt;
  Temp  : Array[1..9] of LongInt;
  Temp2 : LongInt;
  ta    : Byte;
begin
  //ソート用配列にデータをコピー
  ta := 1;
  for x := -1 to 1 do
  begin
    for y := -1 to 1 do
    begin
      Temp[ta] := RGB(Data[x,y].R,Data[x,y].G,Data[x,y].B);
      inc(ta);
    end;
  end;

  //ソート
  for x := 9 DownTo 1 do
  begin
    for y := 2 to x do
    begin
      if Temp[y-1] > Temp[y] then
      begin
        Temp2     := Temp[y];
        Temp[y]   := Temp[y-1];
        Temp[y-1] := Temp2;
      end;
    end;
  end;
  Sort := Temp[Point];
end;



begin

  //抽出値設定
  Point := iPower;


  //フィルタビットマップの生成
  FilterBMP := TBitMap.Create;
  try
  //フィルタビットマップのサイズ設定
  FilterBMP.Assign(BMP);
  FilterBMP.PixelFormat := pf24Bit;

  BMP.PixelFormat := pf24Bit;

  //フィルタ
  for y:=1 to BMP.Height-2 do begin
      PBit:=BMP.ScanLine[y];
      for x:=1 to BMP.Width-2 do begin

      //現画像から値の抽出
        for fy:=-1 to 1 do begin
          pBit2:=FilterBMP.ScanLine[y+fy];
          for fx:=-1 to 1 do begin
             i:=(x+fx)*3;


             pxlRGB[fx,fy].R := PBit2[i];
             inc(i);
             pxlRGB[fx,fy].G := PBit2[i];
             inc(i);
             pxlRGB[fx,fy].B := PBit2[i];
             inc(i);
          end;
        end;


      //値抽出フィルタ
      Median := Sort(pxlRGB,Point);

      //フィルタビットマップに描画
      i:=X*3;
      PBit[i]:=GetRValue(Median);
      inc(i);
      PBit[i]:=GetGValue(Median);
      inc(i);
      PBit[i]:=GetBValue(Median);

    end;
  end;



  finally
  //フィルタビットマップの解放
  FilterBMP.Free;
  end;

end;

procedure Bright(BMP:TBitmap;iPower:SmallInt);
var
  x,y  :SmallInt;  //ビットマップのＸ軸、Ｙ軸
  PBit :PByteArray;
  w    :Integer;
begin


  BMP.PixelFormat := pf24Bit;

  w:=(BMP.Width*3-1);

  //明るさ処理
  for y:=0 to BMP.Height-1 do begin
     pBit:=BMP.ScanLine[y];

     for x:=0 to w do begin
         pBit[x]:=RoundByte(pBit[x]+iPower);
     end;
  end;
end;



procedure MonoAllAdd(BMP:TBitmap);
var
  x,y,i,a :SmallInt;  //ビットマップのＸ軸、Ｙ軸
  PBit    :PByteArray;
begin


  BMP.PixelFormat := pf32Bit;


  //コントラスト強調処理
  for y := 0 to BMP.Height-1 do
  begin

    pBit:=BMP.ScanLine[y];
    i:=0;
    for x := 0 to BMP.Width-1 do
    begin

      //Ｙ
      a:=(pBit[i]+pBit[i+1]+pBit[i+2]) div 3;

      pBit[i]:=a;
      inc(i);
      pBit[i]:=a;
      inc(i);
      pBit[i]:=a;
      inc(i,2);

    end;
  end;
end;

procedure xDivide(BMP:TBitmap;iPower:Integer);
var
  x,y,i,b:SmallInt;  //ビットマップのＸ軸、Ｙ軸
  PBit    :PByteArray;
begin
  //量子化

  b:=256 div iPower;

  BMP.PixelFormat := pf32Bit;


  //コントラスト強調処理
  for y := 0 to BMP.Height-1 do
  begin

    pBit:=BMP.ScanLine[y];
    i:=0;
    for x := 0 to BMP.Width-1 do
    begin

      //Ｙ

      pBit[i]:=RoundByte((pBit[i] div b)*b);
      inc(i);
      pBit[i]:=RoundByte((pBit[i] div b)*b);
      inc(i);
      pBit[i]:=RoundByte((pBit[i] div b)*b);
      inc(i,2);

    end;
  end;
end;


procedure MonoYUV(BMP:TBitmap);
var
  x,y,i,a :SmallInt;  //ビットマップのＸ軸、Ｙ軸
  PBit    :PByteArray;
begin


  BMP.PixelFormat := pf32Bit;


  //コントラスト強調処理
  for y := 0 to BMP.Height-1 do
  begin

    pBit:=BMP.ScanLine[y];
    i:=0;
    for x := 0 to BMP.Width-1 do
    begin


      //Ｙ
      a:=RoundByte(Round(0.299*pBit[i]+0.587*pBit[i+1]+0.114*pBit[i+2]));

      pBit[i]:=a;
      inc(i);
      pBit[i]:=a;
      inc(i);
      pBit[i]:=a;
      inc(i,2);

    end;
  end;
end;


procedure AllAdd2(BMP:TBitmap);
var
  x,y,i:SmallInt;  //ビットマップのＸ軸、Ｙ軸
  R,G,B:Byte;      //Ｒ値、Ｇ値、Ｂ値
  PBit :PByteArray;
begin

  BMP.PixelFormat := pf24Bit;

  //コントラスト強調処理
  for y := 0 to BMP.Height-1 do
  begin

    pBit:=BMP.ScanLine[y];
    i:=0;
    for x := 0 to BMP.Width-1 do
    begin

      r:=pBit[i];
      g:=pBit[i+1];
      b:=pBit[i+2];

      R:=(R+G+B) div 3;
      G:=(R+G+B) div 3;
      B:=(R+G+B) div 3;

      pBit[i]  :=r;
      pBit[i+1]:=g;
      pBit[i+2]:=b;

      inc(i,3);

    end;
  end;
end;

procedure Vivid(BMP:TBitmap;iPower:Byte);
var
  x,y,i:SmallInt;  //ビットマップのＸ軸、Ｙ軸
  R,G,B:Byte;      //Ｒ値、Ｇ値、Ｂ値
  PBit :PByteArray;
  iP   :SmallInt;
begin

  BMP.PixelFormat := pf24Bit;

  iP:=(128-iPower) div 2;


  //鮮やかさ処理
  for y := 0 to BMP.Height-1 do
  begin

    pBit:=BMP.ScanLine[y];
    i:=0;
    for x := 0 to BMP.Width-1 do
    begin

      r:=pBit[i];
      g:=pBit[i+1];
      b:=pBit[i+2];

      pBit[i]:=RoundByte((R*iPower shr 7)+(iP*G shr 7)+(iP*B shr 7));
      inc(i);
      pBit[i]:=RoundByte((R*iP shr 7)+(iPower*G shr 7)+(iP*B shr 7));
      inc(i);
      pBit[i]:=ROundByte((R*iP shr 7)+(iP*G shr 7)+(iPower*B shr 7));
      inc(i);

    end;
  end;
end;

Function RoundByte(data:Integer):Byte;
begin
  if Data>255 then Data:=255
  else if Data< 0 then Data:=0;

  Result:=Data;
end;

procedure ColToRGB(Color:TColor;var R,G,B:BYTE);
var pxlRGB:LongInt;
begin

 pxlRGB:=ColorToRGB(Color);
 B:=GetRValue(pxlRGB);
 g:=GetGValue(pxlRGB);
 R:=GetBValue(pxlRGB);

end;

//バージョン４．最適化によってマスクなしでもかなり速い！バグも解消！
// 3/15 テーブル作成で高速化




procedure SuperTextOut(Canvas:TCanvas;X,Y:Integer;bFont:TFont;Msg:String);
var x2,y2,x3,x4,y4,i:Integer;//ループ用
    Pr,Pg,Pb :Integer;//加算平均値
    n      :Integer;//サンプリング値
    BMP,BMP3 :TBitmap;
    Size     :TSize;
    PBit,PBit3,PBit2: PByteArray;
    pABit    :array[0..2] of PByteArray;
    ADatas   :PInteger;
    W,H      :Integer;//幅
    mj       :Integer;
    iA,iA2   :DWORD;
    k3,k4:Integer;//先に計算してしまう
    iStd     :Integer;
    r,g,b    :byte;
    alw,lw:LongWord;
    li    :LongInt;
    SrcLine,DestLine:array of Pointer;
begin
   li:=ColorToRGB(bFont.Color);

   b:=GetRValue(li);
   g:=GetGValue(li);
   r:=GetBValue(li);

 //サンプリング値を１（３倍の範囲から生成）と設定する
 n:=1;
 iStd:=2*n+1;

 //クリエイト
 BMP:=TBitmap.Create;
 BMP3:=TBitmap.Create;
 try

  //設定を代入
  BMP3.Canvas.Font.Assign(bFOnt);
  BMP.Canvas.Font.Assign(bFOnt);
  BMP.Canvas.Font.Size  :=bFOnt.Size*iStd;

  //サイズは小さいほうに合わせる
  Size:=BMP.Canvas.TextExtent(Msg);

  //幅の設定
  W:=(Size.cx div 3)+1;
  H:=(Size.cy div 3)+1;

  //サイズを確定
  BMP.Width  :=W*3;
  BMP.Height :=H*3;
  BMP3.Width :=W;
  BMP3.Height:=H;

  BMP.PixelFormat := pf32Bit;
  BMP3.PixelFormat := pf32Bit;

  //拡大して入力
  BitBlt(BMP3.Canvas.Handle,1,1,W,H,Canvas.Handle,x,y,SRCCOPY);

  //文字描画
  BMP.Canvas.Brush.Style:=bsClear;
  BMP.Canvas.Font.Color :=clWhite;
  BMP.Canvas.Brush.Color:=clBlack;
  BMP.Canvas.Pen.Color  :=clBlack;
  BMP.Canvas.Rectangle(0,0,BMP.Width,BMP.Height);
  BMP.Canvas.TextOut(3,3,msg);


  mj:=((iStd)*(iStd));

  k3:=(1*iStd)-1;

  //キャッシュ
  SetLength(SrcLine,BMP.Height);
  SetLength(DestLine,BMP3.Height);

  for y2:=0 to BMP.Height-1 do begin
      SrcLine[y2] :=BMP.ScanLine[y2];
  end;

  for y2:=0 to BMP3.Height-1 do begin
      DestLine[y2]:=BMP3.ScanLine[y2];
  end;


  for y2:=1 to BMP3.Height-1 do begin

      //Ｙラインの取得
      Pbit3:=DestLine[y2];

      //外に置いて高速化

      //スキャンライン取得を前で実行
      pABit[0]:=SrcLine[k3];
      inc(k3);
      pABit[1]:=SrcLine[k3];
      inc(k3);
      pABit[2]:=SrcLine[k3];
      inc(k3);


      //先に計算
      x3:=4;
      k4:=8;

      for x2:=1 to BMP3.Width-1 do begin

          //ＲＧＢの取得
             Pr:=0;
             for x4:=0 to 2 do begin
                 //読み込み
                 inc(Pr,PABit[0][k4]);
                 inc(Pr,PABit[1][k4]);
                 inc(Pr,PABit[2][k4]);
                 inc(k4,4);
             end;


             //平均値を出す
             //書き込み


             iA2:=Pr div mj;
             iA :=256-iA2;

             pBit3[x3]:=(pBit3[x3]*iA+r*iA2) shr 8;
             inc(x3);
             pBit3[x3]:=(pBit3[x3]*iA+g*iA2) shr 8;
             inc(x3);
             pBit3[x3]:=(pBit3[x3]*iA+b*iA2) shr 8;
             inc(x3,2);
      end;
  end;

   BitBlt(Canvas.Handle,x,y,W,H,BMP3.Canvas.Handle,1,1,SRCCOPY);


  finally
    //解放
    BMP.Free;
    BMP3.Free;
  end;

end;



procedure SuperTextOut2(Canvas:TCanvas;X,Y,W,H:Integer;bFont:TFont;Msg:String; PDxArray: Pointer ;Options: Integer);
const   MaxLineCharacter    = 1000;
var x2,y2,x3,x4,y4,i:Integer;//ループ用
    Pr,Pg,Pb :Integer;//加算平均値
    n      :Integer;//サンプリング値
    BMP,BMP3 :TBitmap;
    Size     :TSize;
    PBit,PBit3,PBit2: PByteArray;
    pABit    :array[0..2] of PByteArray;
    ADatas   :PInteger;
    mj       :Integer;
    iA,iA2   :DWORD;
    k3,k4:Integer;//先に計算してしまう
    iStd     :Integer;
    r,g,b    :byte;
    alw,lw:LongWord;
    li    :LongInt;
    SrcLine,DestLine:array of Pointer;
    ARect: TRect;
    j, xx, ww: Integer;
begin
   li:=ColorToRGB(bFont.Color);

   b:=GetRValue(li);
   g:=GetGValue(li);
   r:=GetBValue(li);

 //サンプリング値を１（３倍の範囲から生成）と設定する
 n:=1;
 iStd:=2*n+1;

 //クリエイト
 BMP:=TBitmap.Create;
 BMP3:=TBitmap.Create;
 try

  //設定を代入
  BMP3.Canvas.Font.Assign(bFOnt);
  BMP.Canvas.Font.Assign(bFOnt);
  BMP.Canvas.Font.Size  :=bFOnt.Size*iStd;


  //サイズは小さいほうに合わせる
  //Size:=BMP.Canvas.TextExtent(Msg);

  //幅の設定
  //W:=(Size.cx div 3)+1;
  //H:=(Size.cy div 3)+1;


  //サイズを確定
  BMP.Width  :=W*3;
  BMP.Height :=H*3;
  BMP3.Width :=W;
  BMP3.Height:=H;

  BMP.PixelFormat := pf32Bit;
  BMP3.PixelFormat := pf32Bit;

  //拡大して入力
  BitBlt(BMP3.Canvas.Handle,1,1,W,H,Canvas.Handle,x,y,SRCCOPY);

  //文字描画
  BMP.Canvas.Brush.Style:=bsClear;
  BMP.Canvas.Font.Color :=clWhite;
  BMP.Canvas.Brush.Color:=clBlack;
  BMP.Canvas.Pen.Color  :=clBlack;
  BMP.Canvas.Rectangle(0,0,BMP.Width,BMP.Height);

  //BMP.Canvas.TextOut(3,3,msg);

  Windows.ExtTextOut(BMP.Canvas.Handle, 0, 0, Options, nil,
        PChar(Msg), Length(Msg), nil);

{
  Windows.ExtTextOut(BMP.Canvas.Handle, 3, 3, Options, nil,
        PChar(Msg), Length(Msg), nil);
}
  mj:=((iStd)*(iStd));

  k3:=(1*iStd)-1;

  //キャッシュ
  SetLength(SrcLine,BMP.Height);
  SetLength(DestLine,BMP3.Height);

  for y2:=0 to BMP.Height-1 do begin
      SrcLine[y2] :=BMP.ScanLine[y2];
  end;

  for y2:=0 to BMP3.Height-1 do begin
      DestLine[y2]:=BMP3.ScanLine[y2];
  end;


  for y2:=1 to BMP3.Height-1 do begin

      //Ｙラインの取得
      Pbit3:=DestLine[y2];

      //外に置いて高速化

      //スキャンライン取得を前で実行
      pABit[0]:=SrcLine[k3];
      inc(k3);
      pABit[1]:=SrcLine[k3];
      inc(k3);
      pABit[2]:=SrcLine[k3];
      inc(k3);


      //先に計算
      x3:=4;
      k4:=8;

      for x2:=1 to BMP3.Width-1 do begin

          //ＲＧＢの取得
             Pr:=0;
             for x4:=0 to 2 do begin
                 //読み込み
                 inc(Pr,PABit[0][k4]);
                 inc(Pr,PABit[1][k4]);
                 inc(Pr,PABit[2][k4]);
                 inc(k4,4);
             end;


             //平均値を出す
             //書き込み


             iA2:=Pr div mj;
             iA :=256-iA2;

             pBit3[x3]:=(pBit3[x3]*iA+r*iA2) shr 8;
             inc(x3);
             pBit3[x3]:=(pBit3[x3]*iA+g*iA2) shr 8;
             inc(x3);
             pBit3[x3]:=(pBit3[x3]*iA+b*iA2) shr 8;
             inc(x3,2);
      end;
  end;

   BitBlt(Canvas.Handle,x,y,W,H,BMP3.Canvas.Handle,1,1,SRCCOPY);


  finally
    //解放
    BMP.Free;
    BMP3.Free;
  end;

end;


procedure SuperTextOutAlpha(Canvas:TCanvas;X,Y:Integer;bFont:TFont;Msg:String;iAlpha:Byte);
var x2,y2,x3,x4,y4,i:Integer;//ループ用
    Pr,Pg,Pb :Integer;//加算平均値
    n      :Integer;//サンプリング値
    BMP,BMP3 :TBitmap;
    Size     :TSize;
    PBit,PBit3: PByteArray;
    W,H      :Integer;//幅
    mj       :Integer;
    iA,iA2   :Byte;
    k3,k4:Integer;//先に計算してしまう
    iStd     :Integer;
    r,g,b    :byte;
    iAlpha2:Byte;
    li    :LongInt;
begin
   li:=ColorToRGB(bFont.Color);
   r:=GetRValue(li);
   g:=GetGValue(li);
   b:=GetBValue(li);

 iAlpha2:=255-iAlpha;


 //サンプリング値を１（３倍の範囲から生成）と設定する
 n:=1;
 iStd:=2*n+1;



 //クリエイト
 BMP:=TBitmap.Create;
 BMP3:=TBitmap.Create;
 try

  //設定を代入
  BMP3.Canvas.Font.Assign(bFOnt);
  BMP.Canvas.Font.Assign(bFOnt);
  BMP.Canvas.Font.Size  :=bFOnt.Size*iStd;

  //サイズは小さいほうに合わせる
  Size:=BMP.Canvas.TextExtent(Msg);

  //幅の設定
  W:=Round(Size.cx / 3)+1;
  H:=Round(Size.cy / 3)+1;

  //サイズを確定
  BMP.Width  :=W*3;
  BMP.Height :=H*3;
  BMP3.Width :=W;
  BMP3.Height:=H;

  BMP.PixelFormat := pf32Bit;
  BMP3.PixelFormat := pf32Bit;

  //拡大して入力
  //StretchBlt(BMP.Canvas.Handle,3,3,BMP.Width,BMP.Height,Canvas.Handle,x,y,W,H,SRCCOPY);
  BitBlt(BMP3.Canvas.Handle,1,1,W,H,Canvas.Handle,x,y,SRCCOPY);

  //文字描画
  BMP.Canvas.Brush.Style:=bsClear;
  BMP.Canvas.Font.Color :=clWhite;
  BMP.Canvas.Brush.Color:=clBlack;
  BMP.Canvas.Pen.Color  :=clBlack;
  BMP.Canvas.Rectangle(0,0,BMP.Width,BMP.Height);
  BMP.Canvas.TextOut(3,3,msg);

  mj:=((iStd)*(iStd));

  k3:=(1*iStd)-1;
  for y2:=1 to BMP3.Height-1 do begin

      //Ｙラインの取得
      PBit3:=BMP3.ScanLine[y2];

      //外に置いて高速化

      //先に計算
      x3:=4;
      k4:=8;

      for x2:=1 to BMP3.Width-1 do begin

          //ＲＧＢの取得
             Pr:=0;

             for y4:=0 to 2 do begin
                 PBit :=BMP.ScanLine[k3+y4];
                 i:=k4;
                 for x4:=1 to 3 do begin
                     //読み込み
                     inc(Pr,PBit[i]);
                     inc(i,4);
                 end;
             end;


             //平均値を出す
             //書き込み


             iA2:=Round(Pr / mj);
             iA :=255-iA2;
             pBit3[x3]:=(((pBit3[x3]*iA+r*iA2) shr 8)*iAlpha+pBit3[x3]*iAlpha2) shr 8;
             inc(x3);
             pBit3[x3]:=(((pBit3[x3]*iA+g*iA2) shr 8)*iAlpha+pBit3[x3]*iAlpha2) shr 8;
             inc(x3);
             pBit3[x3]:=(((pBit3[x3]*iA+b*iA2) shr 8)*iAlpha+pBit3[x3]*iAlpha2) shr 8;
             inc(x3,2);

             //計算を早くやる
             inc(k4,12);

      end;

      //高速化の外だし
      inc(k3,iStd);

  end;

   BitBlt(Canvas.Handle,x,y,W,H,BMP3.Canvas.Handle,1,1,SRCCOPY);

  finally
    //解放
    BMP.Free;
    BMP3.Free;
  end;

end;

procedure StdTextOutFast(iNo,x,y:Integer;text:String;bFOnt:TFont;Col:TColor;Canvas:TCanvas);
var dFont:TFOnt;
    i,i2 :Integer;
begin

  dFont:=TFOnt.Create;
  try
   dFont.Assign(Canvas.Font);
   Canvas.Font.Assign(bFont);

   Canvas.Brush.Style:=bsClear;
   case iNo of
        0:begin
           Canvas.TextOut(x,y,text);
          end;
        1:begin
           //縁取り
           Canvas.Font.Color:=Col;
           Canvas.TextOut(x+1,y+1,text);
           Canvas.TextOut(x+1,y  ,text);
           Canvas.TextOut(x+1,y-1,text);
           Canvas.TextOut(x  ,y+1,text);
           Canvas.TextOut(x  ,y-1,text);
           Canvas.TextOut(x-1,y+1,text);
           Canvas.TextOut(x-1,y  ,text);
           Canvas.TextOut(x-1,y-1,text);
           Canvas.Font.Color:=dFont.Color;
           Canvas.TextOut(x,y,text);
          end;
        2:begin
           //影
           Canvas.Font.Color:=Col;
           Canvas.TextOut(x+2,y+2,text);
           Canvas.Font.Color:=dFont.Color;
           Canvas.TextOut(x,y,text);
          end;
        3:begin
           //がたがたＸ
           Randomize;
           Canvas.TextOut(x+Random(bFOnt.Size div 3),y,text);
          end;
        4:begin
           //がたがたＹ
           Randomize;
           Canvas.TextOut(x,y+Random(bFOnt.Size div 3),text);
          end;
        5:begin
           //がたがたＸＹ
           Randomize;
           i:=Random(bFOnt.Size div 3);
           Randomize;
           i2:=Random(bFOnt.Size div 3);
           Canvas.TextOut(x+i,y+i2,text);
          end;
        6:begin
           //彫り
           Canvas.Font.Color:=Col;
           Canvas.TextOut(x-1,y-1,text);
           Canvas.Font.Color:=dFont.Color;
           Canvas.TextOut(x,y,text);
          end;
   end;

   Canvas.Font.Assign(dFont);

  finally
   dFont.Free;
  end;
end;

procedure StdTextOut(iNo,x,y:Integer;text:String;bFOnt:TFont;Col:TColor;Canvas:TCanvas);
var cFOnt:TFOnt;
    i,i2 :Integer;
begin

  cFOnt:=TFOnt.Create;
  try
   cFOnt.Assign(bFOnt);
   case iNo of
        0:begin
           SupertextOut(Canvas,x,y,bFont,Text);
          end;
        1:begin
           //縁取り
           cFOnt.Color:=Col;
           SupertextOut(Canvas,x+1,y+1,cFont,Text);
           SupertextOut(Canvas,x+1,y,cFont,Text);
           SupertextOut(Canvas,x+1,y-1,cFont,Text);
           SupertextOut(Canvas,x,y+1,cFont,Text);
           SupertextOut(Canvas,x,y-1,cFont,Text);
           SupertextOut(Canvas,x-1,y+1,cFont,Text);
           SupertextOut(Canvas,x-1,y,cFont,Text);
           SupertextOut(Canvas,x-1,y-1,cFont,Text);
           //Canvas.Font.Color:=bFont.Color;
           SupertextOut(Canvas,x,y,bFont,Text);
          end;
        2:begin
           //影
           cFOnt.Color:=Col;
           SupertextOut(Canvas,x+2,y+2,cFont,Text);
           SupertextOut(Canvas,x,y,bFont,Text);
          end;
        3:begin
           //がたがたＸ
           Randomize;
           SupertextOut(Canvas,x+Random(bFOnt.Size div 3),y,cFont,Text);
          end;
        4:begin
           //がたがたＹ
           Randomize;
           SupertextOut(Canvas,x,y+Random(bFOnt.Size div 3),cFont,Text);
          end;
        5:begin
           //がたがたＸＹ
           Randomize;
           i:=Random(bFOnt.Size div 3);
           Randomize;
           i2:=Random(bFOnt.Size div 3);
           SupertextOut(Canvas,x+i,y+i2,cFont,Text);
          end;
        6:begin
           //彫り
           SupertextOut(Canvas,x-1,y-1,bFont,Text);
           cFOnt.Color:=Col;
           SupertextOut(Canvas,x,y,cFont,Text);
          end;
   end;

  finally
   cFOnt.Free;
  end;
end;

procedure StdTextOut_Fly(iNo,x,y:Integer;text:String;bFOnt:TFont;Col:TColor;Canvas:TCanvas);
var cFOnt:TFOnt;
    i,i2 :Integer;
begin

  cFOnt:=TFOnt.Create;
  try
   cFOnt.Assign(bFOnt);
   case iNo of
        0:begin
           SupertextOut_Fly(Canvas,x,y,bFont,Text);
          end;
        1:begin
           //縁取り
           SupertextOut_Fly(Canvas,x+1,y+1,bFont,Text);
           SupertextOut_Fly(Canvas,x+1,y,bFont,Text);
           SupertextOut_Fly(Canvas,x+1,y-1,bFont,Text);
           SupertextOut_Fly(Canvas,x,y+1,bFont,Text);
           SupertextOut_Fly(Canvas,x,y-1,bFont,Text);
           SupertextOut_Fly(Canvas,x-1,y+1,bFont,Text);
           SupertextOut_Fly(Canvas,x-1,y,bFont,Text);
           SupertextOut_Fly(Canvas,x-1,y-1,bFont,Text);
           cFOnt.Color:=Col;
           SupertextOut_Fly(Canvas,x,y,cFont,Text);
          end;
        2:begin
           //影
           cFOnt.Color:=Col;
           SupertextOut_Fly(Canvas,x+2,y+2,cFont,Text);
           SupertextOut_Fly(Canvas,x,y,bFont,Text);
          end;
        3:begin
           //がたがたＸ
           Randomize;
           SupertextOut_Fly(Canvas,x+Random(bFOnt.Size div 3),y,cFont,Text);
          end;
        4:begin
           //がたがたＹ
           Randomize;
           SupertextOut_Fly(Canvas,x,y+Random(bFOnt.Size div 3),cFont,Text);
          end;
        5:begin
           //がたがたＸＹ
           Randomize;
           i:=Random(bFOnt.Size div 3);
           Randomize;
           i2:=Random(bFOnt.Size div 3);
           SupertextOut_Fly(Canvas,x+i,y+i2,bFont,Text);
          end;
        6:begin
           //彫り
           SupertextOut_Fly(Canvas,x-1,y-1,bFont,Text);
           cFOnt.Color:=Col;
           SupertextOut_Fly(Canvas,x,y,cFont,Text);
          end;
   end;

  finally
   cFOnt.Free;
  end;
end;

procedure GetBMP128(iNo,p:Integer;InBMP,OutBMP2:TBitmap);
var ts :TPoint;
begin
  //幅より

  ts:=UnOpeXY32(iNo,InBMP.Width,p);

  BitBlt(OutBMP2.Canvas.Handle,0,0,p,p,InBMP.Canvas.Handle,ts.x*p,ts.y*p,SRCCOPY);

end;

procedure GetBMP128s(iNo,p:Integer;InBMP,OutBMP2:TBitmap);
var ts :TPoint;
begin
  //高さより

  ts:=UnOpeXY32s(iNo,InBMP.Height,p);

  BitBlt(OutBMP2.Canvas.Handle,0,0,p,p,InBMP.Canvas.Handle,ts.x*p,ts.y*p,SRCCOPY);

end;

function  UnOpeXY32(iNo,w,p:Integer):TPoint;
var i :Integer;
    ts:TPoint;
begin

    //横を計算
    i:=w div p;

    //ＸＹを取得
    ts.y:=iNo div i;
    ts.x:=iNo-ts.y*i;

    Result:=ts;

end;

function  UnOpeXY32s(iNo,h,p:Integer):TPoint;
var i :Integer;
    ts:TPoint;
begin

    //横を計算
    i:=h div p;

    //ＸＹを取得
    ts.x:=iNo div i;
    ts.y:=iNo-ts.x*i;

    Result:=ts;

end;

procedure BMPAutoSizeChange(w2,h2:Integer;BMP:TBitmap);
var BMP2   :TBitmap;
    T,L,W,H:Integer;
begin

      T:=0;
      L:=0;

      if BMP.Width > BMP.Height then begin
          W:=W2;
          H:=W2*BMP.Height div BMP.Width;
          T:=(h2-H) div 2;
      end else begin
          H:=H2;
          W:=H2*BMP.Width div BMP.Height;
          L:=(w2-W) div 2;
      end;

      BMP2:=TBitmap.Create;

      BMP2.Width :=W;
      BMP2.Height:=H;
      BMP2.Canvas.StretchDraw(Rect(0,0,W,H),BMP);

      BMP.Assign(nil);
      BMP.Width :=W2;
      BMP.Height:=H2;
      BMP.Canvas.Draw(L,T,BMP2);

      BMP2.Free;

end;

procedure BMPAutoSizeChangeBlack(w2,h2:Integer;BMP:TBitmap);
var BMP2   :TBitmap;
    T,L,W,H:Integer;
begin

      T:=0;
      L:=0;

      if BMP.Width > BMP.Height then begin
          W:=W2;
          H:=W2*BMP.Height div BMP.Width;
          T:=(h2-H) div 2;
      end else begin
          H:=H2;
          W:=H2*BMP.Width div BMP.Height;
          L:=(w2-W) div 2;
      end;

      BMP2:=TBitmap.Create;

      BMP2.Width :=W;
      BMP2.Height:=H;
      BMP2.Canvas.StretchDraw(Rect(0,0,W,H),BMP);

      BMP.Assign(nil);
      BMP.Width :=W2;
      BMP.Height:=H2;
      BMP.Canvas.Brush.Style := bsSolid;
      BMP.Canvas.Brush.Color := $0;
      BMP.Canvas.Rectangle(0,0,W2,H2);
      BMP.Canvas.Draw(L,T,BMP2);

      BMP2.Free;

end;


procedure BMPAutoSizeChangeOut(w2,h2:Integer;BMP,BMP3:TBitmap);
var T,L,W,H:Integer;
    BMP2   :TBitmap;
begin

      T:=0;
      L:=0;

      if BMP.Width > BMP.Height then begin
          W:=W2;
          H:=W2*BMP.Height div BMP.Width;
          T:=(h2-H) div 2;
      end else begin
          H:=H2;
          W:=H2*BMP.Width div BMP.Height;
          L:=(w2-W) div 2;
      end;

      BMP2:=TBitmap.Create;

      BMP2.Width :=W;
      BMP2.Height:=H;
      BMP2.Canvas.StretchDraw(Rect(0,0,W,H),BMP);

      BMP3.Width :=W2;
      BMP3.Height:=H2;
      BMP3.Canvas.Draw(L,T,BMP2);

      BMP2.Free;

end;

procedure BMPSizeChangeAspect(w2,h2:Integer;BMP:TBitmap);
var BMP2:TBitmap;
    W,H :Integer;
begin


      if BMP.Width > BMP.Height then begin
          W:=W2;
          H:=W2*BMP.Height div BMP.Width;
      end else begin
          H:=H2;
          W:=H2*BMP.Width div BMP.Height;
      end;

      BMP2:=TBitmap.Create;
      try
      
        BMP2.Width :=W;
        BMP2.Height:=H;
        BMP2.Canvas.StretchDraw(Rect(0,0,W,H),BMP);

        BMP.Assign(BMP2);
      finally
        BMP2.Free;
      end;
end;


procedure Nega(BMP:TBitmap);
var
  x,y :Integer;  //ビットマップのＸ軸、Ｙ軸
  pBit:pByteArray;
begin
   BMP.PixelFormat := pf24bit;

   //　ネガポジ
   for y := 0 to BMP.Height-1 do begin
       pBit:=BMP.ScanLine[y];
       for x := 0 to (BMP.Width*3-1) do begin
           pBit[x]:=255-pBit[x];
       end;
    end;
end;

procedure Nega32(x,y,w,h:Integer;BMP:TBitmap);
var
  ax,ay,aw,ah,i,j :Integer;  //ビットマップのＸ軸、Ｙ軸
  pBit:pByteArray;
begin
   BMP.PixelFormat := pf32bit;

   If y+h>BMP.Height then ah:=BMP.Height-1
   else ah:=y+h-1;

   If x+w>BMP.Width then aw:=(BMP.Width-1)*4
   else aw:=(x+w-1)*4;



   //　ネガポジ
   j:=x*4;
   for ay := y to ah do begin
       pBit:=BMP.ScanLine[ay];
       i:=j;

       for ax:=j to aw do begin
           pBit[i]:=255-pBit[i];
           inc(i);
       end;
    end;
end;

//参考(勝手にコピー＆勝手に高速化)　
// http://www.ngy.1st.ne.jp/~kengo/

procedure BMP8x8Moz(BMP:TBitmap;AX,AY,BX,BY:Integer;bTate:Boolean);
var
  bmpdest,bmpsource:TRect ;
  Bmp2             :Tbitmap;
  i,b              :Integer;
begin

  BMP2:=TBitmap.Create;

  Bmp2.Width :=BX-AX;
  Bmp2.Height:=BY-AY;

  bmpdest.top    := 0 ;
  bmpdest.left   := 0 ;
  bmpdest.right  := Bmp2.Width ;
  bmpdest.bottom := Bmp2.Height ;

  bmpsource.top    := AX;
  bmpsource.left   := AY;
  bmpsource.right  := BX;
  bmpsource.bottom := BY;

  Bmp2.canvas.copyrect(bmpdest,BMP.canvas,bmpsource) ;

  If bTate then begin
    //無駄な書き換え処理は外部に置く
    bmpdest.top   :=AX;
    bmpdest.bottom:=BY;
    bmpsource.top   :=0;
    bmpsource.bottom:=Bmp2.Height;

    for i := 1 to (bmp2.Width div 8) do begin
        b:=(i-1)*8;
        bmpdest.left  :=AX+b+8-1;
        bmpdest.right :=AX+b-1;

        bmpsource.left  :=b;
        bmpsource.right :=b+8;
        BMP.Canvas.copyrect(bmpdest,bmp2.canvas,bmpsource) ;
    end;
  end else begin

    //無駄な書き換え処理は外部に置く
    bmpdest.left   :=AX;
    bmpdest.right  :=BX;
    bmpsource.left :=0;
    bmpsource.right:=bmp2.width;

    for i := 1 to (bmp.Height div 8) do begin
        b:=(i-1)*8;
        bmpdest.top    :=AY+b+8-1;
        bmpdest.bottom :=AY+b-1;

        bmpsource.top   :=b;
        bmpsource.bottom:=b+8;
        BMP.canvas.copyrect(bmpdest,bmp2.canvas,bmpsource) ;
    end;
  end;

  bmp2.free ;

end;

procedure BMPWinMoz(BMP:TBitmap;AX,AY,BX,BY:Integer);
var
  bmpdest,bmpsource:TRect ;
  Bmp1: Tbitmap;
  x,i,j,a,b : integer;
begin

  Bmp1 := Tbitmap.Create;
  Bmp1.Width :=BX-AX;
  Bmp1.Height:=BY-AY;

  if (bmp1.Width mod 16)= 0 then begin
     x:=(Bmp1.Width div 16)-1;
  end else begin
     x:=Bmp1.Width div 16;
  end;

  Bmp1.Width:=(x+1)*16 ;

  bmpdest.top   :=0 ;
  bmpdest.left  :=0 ;
  bmpdest.right :=Bmp1.Width ;
  bmpdest.bottom:=Bmp1.Height ;

  bmpsource.top    :=AY;
  bmpsource.left   :=AY;
  bmpsource.right  :=AX+Bmp1.Width;
  bmpsource.bottom :=BY;

  Bmp1.canvas.copyrect(bmpdest,BMP.canvas,bmpsource) ;

  a:=0 ;

  //無駄な処理は外に出す
  bmpdest.top   :=AY;
  bmpdest.bottom:=BY;
  bmpsource.top   :=0;
  bmpsource.bottom:=bmp1.Height ;

  for i:=0 to x do begin
      b:=i*16;
      for j:=0 to 15 do begin

          case j of
              0:a:=12;
              1:a:=8;
              2:a:=6;
              3:a:=15;
              4:a:=9;
              5:a:=13;
              6:a:=2;
              7:a:=11;
              8:a:=1;
              9:a:=4;
              10:a:=14;
              11:a:=7;
              12:a:=0;
              13:a:=5;
              14:a:=10;
              15:a:=3;
           end;

           bmpdest.left  :=AX+b+j;
           bmpdest.right :=AX+b+j+1;

           bmpsource.left  :=b+a;
           bmpsource.right :=b+a+1;

           BMP.canvas.copyrect(bmpdest,Bmp1.canvas,bmpsource) ;

        end;
   end;
   bmp1.free;
end;

procedure BMPFLMoz(BMP3:TBitmap;AX,AY,BX,BY:Integer);
var
  bmpdest,bmpsource : trect ;
  Bmp: Tbitmap;
  i,j,y,x1,y1,m,w,h,k,l,muki:integer;
  bmp1:array[0..640,0..480] of WORD;
  bmp2:array[0..14400] of WORD;
  a,b,c:Integer;
  bmpl1a:TList;
  bmpl1b:TList;
  bmpl2:TList;
  pos  :TPoint;
  po   :Pointer;
begin

  w:=(BX-AX)div 8 ; //横マス数
  h:=(BY-AY)div 8 ; //縦マス数
  If (w*8>640) or (h*8>480) then exit;


  bmpl1a:=TList.Create;
  bmpl2:=TList.Create;
  Bmp  :=Tbitmap.Create;
  try
   Bmp.Width := w * 8 ;
   Bmp.Height := h * 8 ;

   bmpdest.top   :=0;
   bmpdest.left  :=0;
   bmpdest.right :=Bmp.Width;
   bmpdest.bottom:=Bmp.Height;

   bmpsource.top   :=AY;
   bmpsource.left  :=AX;
   bmpsource.right :=AX+Bmp.Width;
   bmpsource.bottom:=AY+Bmp.Height;

   Bmp.canvas.copyrect(bmpdest,BMP3.canvas,bmpsource);

   for i:= 1 to h do begin
       bmpl1b:=TList.Create;
       for j := 1 to w do begin
           po:=Pointer((i - 1) * w + j);
           bmpl1b.Add(po);

           po:=Pointer(0);
           bmpl2.Add(po);
       end;
       bmpl1a.Add(bmpl1b);
   end;

   //渦巻き抽出
   //初期位置
   y:=h;
   m:=1;
   x1:=0;
   y1:=0;
   muki:=1;

   while (m-1<w*h) do begin
     if muki = 1 then begin //right
        for i:=1+x1 to w-x1 do begin
            bmp2[m]:=bmp1[i,h-y1] ;
            inc(m);
        end;
     inc(y1);
   end;

   if muki=2 then begin //up
      for i:= y-y1 downto y1 do begin
          bmp2[m]:=bmp1[w-x1,i];
          inc(m);
      end;
      inc(x1);
   end;

   if muki = 3 then begin //left
      for i:=w-x1 downto x1 do begin
          bmp2[m]:=bmp1[i,y1];
          inc(m);
      end;
   end;

   if muki=4 then begin //down
      for i:=1+y1 to h-y1 do begin
          bmp2[m]:=bmp1[x1,i] ;
          inc(m);
      end;
   end;

   if muki=4 then muki:=1
   else inc(muki);
  end;

  //渦巻き置き換え
  //初期位置
  y:=h;
  x1:=0;
  y1:=0;
  muki:=1;
  dec(m);

  while (m>0) do begin

    case muki of
       1:begin //right
           for i:=1 + x1 to w-x1 do begin
               bmp1[i,h-y1]:=bmp2[m] ;
               dec(m);
           end;
           inc(y1);
         end;
       2:begin //up
           for i:=y-y1 downto y1 do begin
               bmp1[w-x1,i]:=bmp2[m] ;
               dec(m);
           end;
           inc(x1);
         end;
       3:begin //left
           for i:=w-x1 downto x1 do begin
               bmp1[i,y1] := bmp2[m] ;
               dec(m);
           end;
         end;
       4:begin //down
           for i:=1+y1 to h-y1 do begin
               bmp1[x1,i]:=bmp2[m] ;
               dec(m);
           end;
         end;
    end;

    if muki=4 then muki:=1
    else inc(muki);
  end;


  for i:= 1 to h do
      for j:=1 to w do begin
          k:=(bmp1[j,i])mod w ;
          l:=(bmp1[j,i])div w ;
          if k = 0 then begin
             k:=W;
             dec(l);
          end;

          a:=(i-1)*8;
          b:=(k-1)*8;

          bmpdest.top   :=AY+a;
          bmpdest.left  :=AX+a;
          bmpdest.right :=AX+a+8 ;
          bmpdest.bottom:=AY+(i-1)*8+8 ;

          bmpsource.top   :=l*8;
          bmpsource.left  :=b;
          bmpsource.right :=b+8;
          bmpsource.bottom:=bmpsource.top+8;

          if bmp1[j,i]<>(i-1)*w+j then BMP3.canvas.copymode := cmNotSrcCopy;
          BMP3.canvas.copyrect(bmpdest,Bmp.canvas,bmpsource) ;
          BMP3.canvas.copymode := cmsrccopy ;
       end;
  finally
    bmp.Free;

    for i:= 1 to h do begin
        bmpl1b:=bmpl1a[i];
        bmpl1b.Free;
    end;

    bmpl1a.Free;
    bmpl2.Free;
  end;
end;

procedure BMPRainBowMoz(BMP3:TBitmap;AX,AY,BX,BY,iDot:Integer);
var
  x,y,x0,y0,r,g,b,u,k,e : integer ;
  edi,t,l,w,h : integer ;
begin

   If BX>AX then begin
      w:=BX-AX;
      t:=AX;
   end else begin
      w:=AX-BX;
      t:=BX;
   end;

   If BY>AY then begin
      h:=BY-AY;
      l:=AY;
   end else begin
      h:=AY-BY;
      l:=BY;
   end;

  edi:=0;

  case iDot of
       1:edi:=1;
       2:edi:=2;
       3:edi:=4;
       4:edi:=8;
       5:edi:=16;
       6:edi:=32;
  end;

  u:=edi+1 ;
  if edi>8 then e:=edi div 8
  else e:=1;

  for y0:=0 to h div edi-1 do begin
      y:=y0*edi+t;
      for x0:=0 to w div edi-1 do begin
          x:=x0*edi+l;
          k := (x0*edi+y0*edi) div e;
          r := (16-abs((k+16) mod 48 -16))*32 ;
          k := k mod 48 ;
          g := (16-abs(k-16))*32 ;
          b := (16-abs(k-32))*32 ;

          if r>255 then r:=255
          else if r<0 then r := 0 ;

          if g> 255 then g:=255
          else if g<0 then g:=0;

          if b>255 then b:=255
          else if b<0 then b:=0;

          with BMP3.Canvas do begin
               Pen.color := rgb(r,g,b) ;
               Pen.Style := psclear ;
               Pen.Mode := pmXor ;
               Brush.color := rgb(r,g,b) ;
               Brush.Style := bsSolid ;
               Rectangle(x,y,x+u ,y+u ) ;
          end;
      end;
   end;
end;

procedure BMPColorMoz(BMP3:TBitmap;AX,AY,BX,BY:Integer);
var
  dest,bmpsource : trect ;
  x,y,i:integer;
  bmp  :tbitmap ;
  r,g,b:BYTE;
  PBit :PByteArray;
begin

 bmp:=TBitmap.create;

 try
  bmp.PixelFormat:=pf24Bit;
   If BX>AX then begin
      bmp.Width:=BX-AX;
   end else begin
      bmp.Width:=AX-BX;
   end;

   If BY>AY then begin
      bmp.Height:=BY-AY;
   end else begin
      bmp.Height:=AY-BY;
   end;

  dest.Top   :=0;
  dest.Left  :=0;
  dest.Right :=bmp.Width;
  dest.Bottom:=bmp.Height;

  bmpsource.top   :=AY;
  bmpsource.left  :=AX;
  bmpsource.right :=BX;
  bmpsource.bottom:=BY;

  bmp.canvas.copyrect(dest,BMP3.canvas,bmpsource);

  for y := 0 to bmp.height-1 do begin
      PBit:=BMP.ScanLine[y];
      for x := 0 to bmp.width-1 do begin
          i:=x*3;
          R:=PBit[i];
          G:=PBit[i+1];
          B:=PBit[i+2];
          PBit[i]:=G;
          PBit[i+1]:=B;
          PBit[i+2]:=R;
      end;
  end;
  BMP3.Canvas.copyrect(bmpsource,bmp.canvas,dest);
  
 finally
  bmp.free;
 end;

end;




procedure Gamma(bPlusMinus:Boolean;BMP:TBitmap);
var
  x,y:Integer;  //ビットマップのＸ軸、Ｙ軸
  Rd :Double;    //Ｒ値、Ｇ値、Ｂ値（実数型）
  pBit      :PByteArray;
begin

 BMP.PixelFormat:=pf24Bit;

  //ガンマ補正処理
 if bPlusMinus then begin//プラス処理

  for y := 0 to BMP.Height-1 do begin
      pBit:=BMP.ScanLine[y];
      for x := 0 to (BMP.Width*3-1) do begin
          //ガンマ補正
          pBit[x] :=roundByte(Round(Sqrt(pBit[x] / 255) * 255.0));
      end;
  end;
 end else begin //マイナスの処理

  for y := 0 to BMP.Height-1 do begin
      pBit:=BMP.ScanLine[y];
      for x := 0 to (BMP.Width*3-1) do begin
          //ガンマ補正
          Rd:=pBit[x] / 255;
          pBit[x] :=roundByte(Round((Rd-(Sqrt(Rd)-Rd)) * 255.0));
      end;
  end;
 end;
end;

procedure NoiseRGBALL(BMP:TBitmap;iEffect:Byte);
var x,y,i:Integer;
    pBit :PByteArray;
    r    :Byte;
begin

  BMP.PixelFormat:=pf24Bit;

  //乱数の発生
  Randomize;

  for y:=0 to BMP.Height-1 do begin
      pBit:=BMP.ScanLine[y];

      RandSeed:=y;

      i:=0;

      for x:=0 to BMP.Width-1 do begin
          //ノイズ処理
          r:=Random(iEffect);

          //ＲＧＢに均等に同じノイズレベルをかける
          pBit[i]:=RoundByte(pBit[i]+r);
          inc(i);

          pBit[i]:=RoundByte(pBit[i]+r);
          inc(i);

          pBit[i]:=RoundByte(pBit[i]+r);
          inc(i);

      end;
  end;
end;

procedure Noise(BMP:TBitmap;iEffect:Byte);
var x,y,w:Integer;
    pBit :PByteArray;
begin

  BMP.PixelFormat:=pf24Bit;
  //乱数の発生
  Randomize;
  w:=(BMP.Width*3-1);

  for y:=0 to BMP.Height-1 do begin
      pBit:=BMP.ScanLine[y];
      RandSeed:=y;
      for x:=0 to w do begin
          //ノイズ処理
          //ＲＧＢにバラバラのノイズレベルをかける
          pBit[x]:=RoundByte(pBit[x]+Random(iEffect));
      end;
  end;

end;

procedure RGBDivide(BMP:TBitmap);
var x,y,i:Integer;
    j    :byte;
    pBit :PByteArray;
begin

  BMP.PixelFormat:=pf24Bit;

  for y:=0 to BMP.Height-1 do begin
      pBit:=BMP.ScanLine[y];
      i:=0;
      j:=y mod 3;

      for x:=0 to (BMP.Width-1) do begin

          case j of
               0:begin
                  inc(i);
                  pBit[i]:=0;
                  inc(i);
                  pBit[i]:=0;
                  inc(i);
                 end;
               1:begin
                  pBit[i]:=0;
                  inc(i);
                  inc(i);
                  pBit[i]:=0;
                  inc(i);
                 end;
               2:begin
                  pBit[i]:=0;
                  inc(i);
                  pBit[i]:=0;
                  inc(i);
                  inc(i);
                 end;
          end;


      end;

  end;

end;

procedure thinRGB(BMP:TBitmap;iPower:Byte);
var x,y,i,a:Integer;
    pBit :PByteArray;
    iA   :Byte;
begin

  BMP.PixelFormat:=pf24Bit;
  iA:=255-iPower;

  for y:=0 to BMP.Height-1 do begin
      pBit:=BMP.ScanLine[y];
      i:=0;
      for x:=0 to (BMP.Width-1) do begin

          a:=pBit[i];
          a:=a+pBit[i+1];
          a:=a+pBit[i+2];

          a:=a div 3;

          pBit[i]:=(((a*iPower) shr 8)+((pBit[i]*iA) shr 8));
          inc(i);
          pBit[i]:=(((a*iPower) shr 8)+((pBit[i]*iA) shr 8));
          inc(i);
          pBit[i]:=(((a*iPower) shr 8)+((pBit[i]*iA) shr 8));
          inc(i);


      end;

  end;

end;

procedure Diffusion(BMP:TBitmap;iPower:Byte);
var x,y,i,j,w,h:Integer;
    pBit :PByteArray;
    BMP2 :TABitmap;
    xa,ya:Integer;
begin

  BMP2:=TABitmap.Create;
  try  
    BMP.PixelFormat:=pf24Bit;
    BMP2.Assign(BMP);

    j:=iPower div 2;
    Randomize;
    w:=BMP.Width-1;
    h:=BMP.Height-1;

    for y:=0 to h do begin
        pBit:=BMP.ScanLine[y];
        i:=0;
        RandSeed:=y;

        for x:=0 to w do begin
            xa:=x+j-Random(iPower);
            ya:=y+j-Random(iPower);
            If xa<0 then xa:=0;
            If xa>w then xa:=w;
            If ya<0 then ya:=0;
            If ya>h then ya:=h;

            BMP2.PutRGB(xa,ya,pBit[i],pBit[i+1],pBit[i+2]);
            inc(i,3);
        end;

    end;
  finally
   BMP.Assign(BMP2);
   BMP2.Free;
  end;
end;

procedure CustomFilter(BMP:TBitmap;bCol:Boolean;Ra,Ga,Ba:BYTE;StrGrid:TStringGrid;iPower:Integer);
type
  tRGB = Record
    R : Byte;
    G : Byte;
    B : Byte;
   end;
var
  Filter : array[-1..1,-1..1] of Double; //フィルタ配列
  Data   : array[-1..1,-1..1] of tRGB;//マスク配列

  x,y    : SmallInt;   //Ｘ軸、Ｙ軸
  fx,fy  : SmallInt;   //Ｘ軸、Ｙ軸（フィルタ演算）

  FilterBMP   : TBitMap; //フィルタ画像

  pxl    : Double;   //ピクセル値
  DataPxl: LongInt;  //ピクセル値
  R,G,B  : Byte;     //ＲＧＢ値
  RevRGB : Double;   //フィルタ差分値
  Raito  : Double;   //差分

  FixedColorCheck : Boolean;    //色指定チェック
  FixedColorR,FixedColorG,FixedColorB : Byte;  //指定色
  exFilter : SmallInt; //フィルタ強度
  PBit,PBit2: PByteArray;
  i,k:Integer;

begin


  //色指定フラグ
  FixedColorCheck := bCol;

  //指定色
  FixedColorR := Ra;
  FixedColorG := Ga;
  FixedColorB := Ba;

  //フィルタ強度
  exFilter := iPower;

  //フィルタ定義
  for fx := 0 to 2 do
  begin
    for fy := 0 to 2 do
    begin
      Filter[fx - 1, fy - 1]:=StrToFloat(strgrid.Cells[fx,fy]);
    end;
  end;


 //フィルタ画像設定
 FilterBMP := TBitMap.Create;
 try
  FilterBMP.Height:=BMP.Height;
  FilterBMP.Width :=BMP.Width;
  FilterBMP.PixelFormat := pf24Bit;
  BMP.PixelFormat := pf24Bit;


  //フィルタ処理
  for y := 1 to (BMP.Height-2 ) do begin

      PBit:=FilterBMP.ScanLine[y];

      for x := 1 to (BMP.Width-2 ) do begin

      k:=(x-1)*3;
      //マトリクス情報取得
      for fy := -1 to 1 do begin
          PBit2:=BMP.ScanLine[y+fy];
          i:=K;
          for fx:=-1 to 1 do begin
              Data[fx,fy].R:=PBit2[i];
              inc(i);
              Data[fx,fy].G:=PBit2[i];
              inc(i);
              Data[fx,fy].B:=PBit2[i];
              inc(i);
        end;
      end;

      //フィルタ演算
      pxl := 0.0;
      for fx := -1 to 1 do begin
        for fy := -1 to 1 do begin
          DataPxl := RGB(Data[fx,fy].R,Data[fx,fy].B,Data[fx,fy].G);
          pxl := pxl + DataPxl * Filter[fx,fy];
        end;
      end;

      //差分値計算
      if RGB(Data[0,0].R,Data[0,0].G,Data[0,0].B) = 0 then
         Raito := 0
      else
         Raito := Pxl / RGB(Data[0,0].R,Data[0,0].G,Data[0,0].B);

      //フィルタ差分値
      RevRGB := Raito * exFilter;

      //画素値
      R := Data[0,0].R;
      G := Data[0,0].G;
      B := Data[0,0].B;

      //フィルタ差分値＋画素値
      if FixedColorCheck then
      begin
        R := RoundByte(Round(FixedColorR + RevRGB));
        G := RoundByte(Round(FixedColorG + RevRGB));
        B := RoundByte(ROund(FixedColorB + RevRGB));
      end
      else
      begin
        R := RoundByte(Round(R + RevRGB));
        G := RoundByte(Round(G + RevRGB));
        B := RoundByte(Round(B + RevRGB));
      end;

      //描画

      i:=X*3;PBit[i]:=R;
      inc(i);PBit[i]:=G;
      inc(i);PBit[i]:=B;
    end;
  end;

  BMP.Assign(FilterBMP);

 finally
  //フィルタビットマップの解放
  FilterBMP.Free;
 end;
end;


procedure Laplacian(Power:Integer;BMP:TBitmap);
var
  x,y,i,j,k   :SmallInt;  //ビットマップのＸ軸、Ｙ軸
  R,G,B     :Integer;      //Ｒ値、Ｇ値、Ｂ値
  PBit,PBit2:PByteArray;
  W,H,x2,y2 :Integer;
  k1,W2     :Integer;
  iA        :Byte;
  SrcLine:array of Pointer;
begin

  //色々実験

  BMP.PixelFormat := pf32Bit;
  H:=BMP.Height-1;
  W:=BMP.Width-1;
  W2:=(W-1)*4;


  iA:=255-Power;

  SetLength(SrcLine,BMP.Height);

  for x:=0 to BMP.Height-1 do begin
      SrcLine[x]:=BMP.ScanLine[x];
  end;

  //コントラスト強調処理
  for y := 1 to H-1 do begin

    k:=4;

    pBit :=SrcLine[y];
    for x := 1 to W-1 do begin

       //初期化
       r:=0;
       g:=0;
       b:=0;


       // 1- 1062ms
       // 2- 1022ms
       // 3- 1011ms
       // 4-


       //ＲＧＢデータ取得
       for y2:=-1 to 1 do begin
              PBit2:=SrcLine[y+y2];

              i:=k-4;

              for x2:=0 to 2 do begin
                     //読み込み

                     r:=r+PBit2[i];
                     inc(i);
                     g:=g+PBit2[i];
                     inc(i);
                     b:=b+PBit2[i];
                     inc(i,2);
               end;
       end;


      pBit[k]:=(RoundByte((pBit[k]*11-R) div 2)*Power shr 8)+(pBit[k]*iA) shr 8;
      inc(k);
      pBit[k]:=(RoundByte((pBit[k]*11-G) div 2)*Power shr 8)+(pBit[k]*iA) shr 8;
      inc(k);
      pBit[k]:=(RoundByte((pBit[k]*11-B) div 2)*Power shr 8)+(pBit[k]*iA) shr 8;
      inc(k,2);



    end;
  end;
end;


function History(iNo:Integer;BMP:TBitmap;var hislist:TStrings):Integer;
var
  x,y,i,y2:Integer;  //ビットマップのＸ軸、Ｙ軸
  R,G,B      :Integer;      //Ｒ値、Ｇ値、Ｂ値
  PBit       :PByteArray;
  W,H        :Integer;
  ar         :array[0..255] of Integer;
  iMax,iMax2 :Integer;
begin

  //色々実験

  BMP.PixelFormat := pf24Bit;
  H:=BMP.Height-1;
  W:=BMP.Width-1;
  hislist.Clear;

  for y:=0 to 255 do begin
      ar[y]:=0;
  end;
  //コントラスト強調処理
  for y := 0 to H do begin
    pBit:=BMP.ScanLine[y];
    for x := 0 to W do begin
      i:=(x)*3;
      R:=pBit[i];
      inc(i);G:=pBit[i];
      inc(i);B:=pBit[i];

      case iNo of
           0:begin
              //赤
              inc(ar[R]);
             end;
           1:begin
              //緑
              inc(ar[G]);
             end;
           2:begin
              //青
              inc(ar[B]);
             end;
           3:begin
              //ＲＧＢ全部平均
              inc(ar[(R+G+B)div 3]);
             end;
           4:begin
              //Ｙ（輝度)
              inc(ar[Trunc(0.299*R+0.587*G+0.114*B)]);
             end;
           5:begin
              //Ｕ
              inc(ar[Trunc(abs(-0.169*R-0.3316*G+0.500*B))]);
             end;
           6:begin
              //Ｖ
              inc(ar[Trunc(abs(0.500*R-0.4186*G-0.0813*B))]);
             end;
      end;
    end;
  end;

  iMax:=0;
  iMax2:=0;
  for y:=0 to 255 do begin
      If ar[y]>iMax then begin
         iMax:=ar[y];
         iMax2:=y;
      end;
  end;

  //255をＭＡＸとした平均値
  for y:=0 to 255 do begin
      y2:=Trunc(ar[y]*(255 /iMax));
      hislist.Add(IntToStr(y2));
  end;

  Result:=iMax2;

end;

procedure Gradation(BMP:TBitmap;AColor,BColor:TColor;isVertical:Boolean);
var x,y,w,h,i:Integer;
    pBit   :PByteArray;
    r,g,b,r2,g2,b2:Byte;
    r3,g3,b3:Byte;
begin

   //サイズの指定
   w:=BMP.Width;
   h:=BMP.Height;
   BMP.PixelFormat:=pf24Bit;

   b :=GetRValue(BColor);
   g :=GetGValue(BColor);
   r :=GetBValue(BColor);
   b2:=GetRValue(AColor);
   g2:=GetGValue(AColor);
   r2:=GetBValue(AColor);

   If isVertical then begin
      for y:=0 to H-1 do begin
          pBit:=BMP.ScanLine[y];
          i:=0;
          for x:=0 to W-1 do begin
              pBit[i]:=((r*x+r2*(W-x)) div W);
              inc(i);
              pBit[i]:=((g*x+g2*(W-x)) div W);
              inc(i);
              pBit[i]:=((b*x+b2*(W-x)) div W);
              inc(i);
          end;
      end;
   end else begin
       for y:=0 to H-1 do begin
           pBit:=BMP.ScanLine[y];
           i:=0;
           r3:=((r*y+r2*(H-y)) div H);
           g3:=((g*y+g2*(H-y)) div H);
           b3:=((b*y+b2*(H-y)) div H);
           
           for x:=0 to W-1 do begin
              pBit[i]:=r3;
              inc(i);
              pBit[i]:=g3;
              inc(i);
              pBit[i]:=b3;
              inc(i);
           end;
       end;
   end;
end;

procedure x2BMP(BMP:TBitmap);
var BMP2:TBitmap;
begin

    BMP2:=TBitmap.Create;
    try
     BMP2.Width :=BMP.Width*2;
     BMP2.Height:=BMP.Height*2;

     StretchBlt(BMP2.Canvas.Handle,0,0,BMP2.Width,BMP2.Height,BMP.Canvas.Handle,0,0,BMP.Width,BMP.Height,SRCCOPY);

     BMP.Assign(BMP2);

    finally
     BMP2.Free;

    end;
end;

//ぱくりの３重苦。気に食わないので私なりの仕組みに改造してますが基本は同じ。
//元＞http://homepage1.nifty.com/beny/delphi.html
//アルゴリズムの解説はわからんとか書いてあったので私が解説。
{ 簡単に言えば、白黒化したら、その明るさに応じた２５５段階の
　色テーブルを当てはめるだけです。応用すれば不気味なセピアが出来るのです。
　以上。}

procedure SepiaSuper(Bitmap: TBitmap;r,g,b:Byte);
var
  X, Y, I      :Integer;
  RTable,GTable,BTable:array[0..255] of Byte;
  pbit         :PByteArray;
  a:byte;
begin

  Bitmap.PixelFormat:=pf24Bit;

  { 変換テーブルを作成 }
  for I := 0 to 127 do begin
      RTable[I]:=((i*r) shr 7);
      GTable[I]:=((i*g) shr 7);
      BTable[I]:=((i*b) shr 7);
      a:=127-i;
      RTable[I+128]:=(((a*r) shr 7)+((i*255) shr 7));
      GTable[I+128]:=(((a*g) shr 7)+((i*255) shr 7));
      BTable[I+128]:=(((a*b) shr 7)+((i*255) shr 7));
  end;

  { ピクセル変換 }
  for Y := 0 to Bitmap.Height -1 do begin
    pbit:=Bitmap.ScanLine[Y];
    i:=0;
    for X := 0 to Bitmap.Width -1 do begin

        a:=(pbit[i]+pBit[i+1]+pBit[i+2]) div 3;

        pBit[i]:=RTable[a];
        inc(i);
        pBit[i]:=GTable[a];
        inc(i);
        pBit[i]:=BTable[a];
        inc(i);
    end;
  end;
end;

{procedure RotateBMPGame(BMP:TBitmap;iPower:Integer);
var x,y:Integer;
    pBit:PbyteArray;
begin


for y:=0 to BMP.Width do begin

  for x:=0 to BMP.Height do begin

  kx:=m-15; //回転の中心にずらす
  ky:=l-15;

  x:=round(kx*cos(r)-ky*sin(r));//回転式
  y:=round(kx*sin(r)+ky*cos(r));

  x:=x+15; //座標を戻す
  y:=y+15;

  //代入(この部分が改良されました。)
  Load_Bmap.Canvas.Pixels[m,l]:=Main_Bmap.Canvas.Pixels[x,y];
  end;
end;
}


//end;



procedure MonoNTSCave(BMP:TBitmap);
var
  x,y,i,a :SmallInt;  //ビットマップのＸ軸、Ｙ軸
  PBit    :PByteArray;
begin


  BMP.PixelFormat := pf24Bit;


  //コントラスト強調処理
  for y := 0 to BMP.Height-1 do
  begin

    pBit:=BMP.ScanLine[y];
    i:=0;
    for x := 0 to BMP.Width-1 do
    begin

      //Ｙ
      a:=( 2*pBit[i] + 4*pBit[i+1] + pBit[i+2] ) div 7 shr 8;

      pBit[i]:=a;
      inc(i);
      pBit[i]:=a;
      inc(i);
      pBit[i]:=a;
      inc(i);

    end;
  end;
end;

procedure LinePic(BMP:TBitmap);
begin
//細線化処理


  //白黒か
  MonoYUV(BMP);

  //量子化
  xDivide(BMP,4);

  //エッジ
  edge(BMP);

  //反転して完成
  Nega(BMP);

end;

//元ソースhttp://homepage1.nifty.com/beny/tips/dib04.html
//これだと、Delphi3じゃ動かないっぽいので変更しまくる
//少々早くなったと思う（変数の代入時の速度低下を無くしたはずなので
procedure Solarization(Bitmap: TBitmap);
// ソラリゼーション
var
  X, Y,w: Integer;
  pLine: PByteArray;
  Table: array[0..255]of Byte;
begin
  Bitmap.PixelFormat := pf24bit;


  { 変換テーブルを生成 }
  for X := 0 to 255 do begin
    //Table[X] := Min(X, X xor $FF);でも良い
    Y := X xor $FF;
    if X < Y then Y := X;
    Table[X] := Y;
  end;


  w:=(Bitmap.Width -1)*3;

  { ピクセルの変換処理 }
  for Y := 0 to Bitmap.Height -1 do begin
    pLine := Bitmap.ScanLine[Y];
    
    for X := 0 to w do begin
        { 先ほど作った変換テーブルを使用する }
        pLine[x]:=Table[pLine[x]];
    end;
  end;
end;



//パクって汎用化・高速化しました。すみません
//引用元 http://www.geocities.co.jp/SiliconValley/2625/delphi/DEL_ROT.HTML
//　　　 http://www.sm.rim.or.jp/~shishido/kaiten.html　　

{procedure Rotate(BMP2:TBitmap;degree:Integer);
var
   x,y:Integer;
   dg,dg90:real;
   bmp:TBitmap;
   pBit,pBit2:pByteArray;
   tx,ty:Integer;
   sx,sy:Integer;
   tp,k,l :Integer;
   sdg,cdg:Integer;
   tw,th,xx,yy:Integer;
   //開始位置
   StX,StY:Integer;
   //増幅分
   ddX,ddY:Integer;

begin

   //コサインサインを求める
   dg:= (360-degree) * PI / 180;
   sdg:=Round(sin(dg) * 1024);
   cdg:=Round(cos(dg) * 1024);




   bmp:=TBitmap.Create;
   bmp.Width :=BMP2.Width;
   bmp.Height:=BMP2.Height;
   bmp.PixelFormat:=pf32bit;
   bmp2.PixelFormat:=pf32bit;


   tw:=bmp2.Width div 2;
   th:=bmp2.Height div 2;

   //増加分を計算する
   //StX:=cdg*(-tw)-sdg*(-th)+(tw shl 10);
   //StY:=sdg*(-tw)+cdg*(-th)+(th shl 10);
   StX:=(tw shl 10);
   StY:=(th shl 10);

   //StX = int_cos * (-DstCX) - int_sin * (-DstCY) + (SrcCY<<10);
   //StY = int_sin * (-DstCX) + int_cos * (-DstCY) + (RrcCY<<10);


   for y:=0 to bmp2.Height-1 do begin
     pBit :=BMP.ScanLine[y];
     k:=0;

     xx:=StX+sdg*y;
     yy:=StY+cdg*y;


     for x:=0 to bmp2.Width-1 do begin
         inc(xx);
         
         //tx:=((xx*cdg-yy*sdg) shr 10)+tw;
         //ty:=((xx*sdg+yy*cdg) shr 10)+th;
         tx:=xx shr 10;
         ty:=yy shr 10;
         inc(xx,cdg);
         inc(yy,sdg);



         If (tx<bmp2.Width) and (ty<bmp2.Height) and (tx>=0) and (ty>=0) then begin
            pBit2:=BMP2.ScanLine[ty];
            l:=tx*4;

            pBit[k]:=pBit2[l];
            inc(k);
            inc(l);
            pBit[k]:=pBit2[l];
            inc(k);
            inc(l);
            pBit[k]:=pBit2[l];
            inc(k,2);
         end else inc(k,4);
   end;
 end;


 BMP2.Assign(BMP);
 bmp.Free;

end;
}

{$R-}
procedure Rotate(srcBmp:TBitmap; degree:Integer);
const
   sOrd  : Integer=10;//シフトの桁
   white : array[0..2] of Byte = ($FF,$FF,$FF);
   pwhite: pByteArray = @white;
var
   rd:real;//角度[rad]
   dstBmp:TBitmap;//変換後の画像
   srd,crd:Integer;//sin,cosを1024倍した整数値
   srcX,srcY,srcCX,srcCY:Integer;
   dstX,dstY,dstCX,dstCY:Integer;
   SrcLine:array of Pointer;//色データへのポインタ配列
   pBit,pBitS0,pBitS1,pBitS2,pBitS3:pByteArray;//色データ
   k,l:Integer;
   x,y,dx,dy,H,W :Integer;
   function Lerp(d:Integer; c0:Integer; c1:Integer):Integer;
   var
     h: Integer;
   begin
     h := d xor $FF; Inc(h);
     Result := (c0 * h + c1 * d) shr 8;
   end;
begin
   //画像初期化
   dstBmp := TBitmap.Create;
   dstBmp.PixelFormat := pf32bit;
   srcBmp.PixelFormat := pf32bit;

   //コサインサインを求める(計算高速化のため整数に)
   rd  := DegToRad(-degree);//逆回転で白点を作らないようにする
   srd := Round(sin(rd) * (1 shl sOrd));//実計算値はshrで戻すこと。
   crd := Round(cos(rd) * (1 shl sOrd));

   //回転後画像の幅・高さを計算する
   dstBmp.Width  := (Abs(srcBmp.Width*crd) + Abs(srcBmp.Height*srd)) shr sOrd;
   dstBmp.Height := (Abs(srcBmp.Width*srd) + Abs(srcBmp.Height*crd)) shr sOrd;

   //画像の中央
   H := srcBmp.Height; W := srcBmp.Width;
   dstCX := dstBmp.Width  div 2;
   dstCY := dstBmp.Height div 2;
   srcCX := W shl (sOrd - 1);
   srcCY := H shl (sOrd - 1);

   //ラインの初期化
   SetLength(SrcLine, H);
   for y:=0 to H-1 do begin
       SrcLine[y] := srcBmp.ScanLine[y];
   end;

   for dstY:=-dstCY to -dstCY+dstBmp.Height-1 do begin
     pBit := dstBmp.ScanLine[dstY+dstCY];
     k:=0;
     for dstX:=-dstCX to -dstCX+dstBmp.Width-1 do begin

       // 平行移動*回転
       srcX := dstX*crd - dstY*srd + srcCX; // [cos -sin   [x    [cx
       srcY := dstX*srd + dstY*crd + srcCY; // sin  cos] *  y] +  cy]

       x := srcX shr sOrd;
       y := srcY shr sOrd;

       // 点(x,y)が元の画像のサイズ+αの範囲に収まるならば
       If (x+1>=0) and (y+1>=0) and (x<W) and (y<H) then begin
         dx := (srcX and $3FF) shr 2; // 0 <= dx< 256
         dy := (srcY and $3FF) shr 2;
         Inc(x); Inc(y); // 条件式で何度も再計算をしないで済むように
         If (x = 0) then begin // エッジのための条件分岐。
           pBitS0 := pwhite; pBitS2 := pwhite;
           If (y = 0) then begin // 左上
             pBitS1 := pwhite; pBitS3 := SrcLine[0];
           end else If (y = H) then begin // 左下
             pBitS1 := SrcLine[H-1]; pBitS3 := pwhite;
           end else begin // 左
             pBitS1 := SrcLine[y-1]; pBitS3 := SrcLine[y];
           end;
         end else If (x = W) then begin
           pBitS1 := pwhite; pBitS3 := pwhite;
           l := (W-1) shl 2;
           If (y = 0) then begin // 右上
             pBitS0 := pwhite;
             pBitS2 := SrcLine[0];
             pBitS2 := @(pBitS2[l])
           end else If (y = H) then begin // 右下
             pBitS0 := SrcLine[H-1];
             pBitS0 := @(pBitS0[l]);
             pBitS2 := pwhite;
           end else begin // 右
             pBitS0 := SrcLine[y-1];
             pBitS0 := @(pBitS0[l]);
             pBitS2 := SrcLine[y];
             pBitS2 := @(pBitS2[l]);
           end;
         end else begin
           l := (x-1) shl 2;//4倍
           If (y = 0) then begin // 上
             pBitS0 := pwhite; pBitS1 := pwhite;
             pBitS2 := SrcLine[0];
             pBitS2 := @(pBitS2[l]);
             pBitS3 := @(pBitS2[4]);
           end else If (y = H) then begin // 下
             pBitS0 := SrcLine[H-1];
             pBitS0 := @(pBitS0[l]);
             pBitS1 := @(pBitS0[4]);
             pBitS2 := pwhite; pBitS3 := pwhite;
           end else begin // 中央
             pBitS0 := SrcLine[y-1];
             pBitS0 := pByteArray(@(pBitS0[l]));
             pBitS1 := pByteArray(@(pBitS0[4]));
             pBitS2 := SrcLine[y];
             pBitS2 := @(pBitS2[l]);
             pBitS3 := @(pBitS2[4]);
           end;
         end;
         //各RGB値毎に線型補完
         pBit[k] := Lerp(dy, Lerp(dx, pBitS0[0], pBitS1[0]), Lerp(dx, pBitS2[0], pBitS3[0]));
         inc(k);
         pBit[k] := Lerp(dy, Lerp(dx, pBitS0[1], pBitS1[1]), Lerp(dx, pBitS2[1], pBitS3[1]));
         inc(k);
         pBit[k] := Lerp(dy, Lerp(dx, pBitS0[2], pBitS1[2]), Lerp(dx, pBitS2[2], pBitS3[2]));
         inc(k,2);
       end else inc(k,4);
     end;
   end;
   //コピーして開放
   srcBmp.Assign(dstBmp);
   dstBmp.Free;
end;

{$R-}
procedure RotateFast(srcBmp:TBitmap; degree:Integer);
const
   sOrd:Integer=10;//シフトの桁
var
   x,y,W,H:Integer;
   rd:real;//角度[rad]
   dstBmp:TBitmap;//変換後の画像
   srd,crd:Integer;//sin,cosを1024倍した整数値
   srcX,srcY:Integer;
   srcXi,srcYi:Integer;
   stX,stY:Integer;
   cx,cy:Integer;
   SrcLine:array of Pointer;//色データへのポインタ配列
   pBit,pBit2:pByteArray;//色データ
   k,l :Integer;//pBit,pBit2用のカウンタ
begin
   //画像初期化
   dstBmp:=TBitmap.Create;
   dstBmp.PixelFormat := pf32bit;
   srcBmp.PixelFormat := pf32bit;

   //コサインサインを求める(計算高速化のため整数に)
   rd  := DegToRad(-degree);//逆回転で白点を作らないようにする
   srd := Round(sin(rd) * (1 shl sOrd));//実計算値はshrで戻すこと。
   crd := Round(cos(rd) * (1 shl sOrd));

   //回転後画像の幅・高さを設定する
   H := srcBmp.Height; W := srcBmp.Width;
   dstBmp.Width  := W;
   dstBmp.Height := H;

   //画像の中央
   cx  := W div 2;
   cy  := H div 2;
   stX := ((1 shl sOrd) - crd)*cx + srd*cy;
   stY := ((1 shl sOrd) - crd)*cx - srd*cy;

   //ラインの初期化
   SetLength(SrcLine, H);
   for y:=0 to H-1 do begin
       SrcLine[y] := srcBmp.ScanLine[y];
   end;

   for y:=0 to H-1 do begin
     pBit := dstBmp.ScanLine[y];
     k:=0;
     srcXi := stX - y*srd;
     srcYi := stY + y*crd;
     for x:=0 to W-1 do begin
       inc(srcXi, crd);
       inc(srcYi, srd);
       srcX := srcXi shr sOrd;
       srcY := srcYi shr sOrd;

       // 点(srcX,srcY)が元の画像のサイズに収まるならば
       If (srcX>=0) and (srcY>=0) and (srcX<W) and (srcY<H) then begin
          pBit2:=SrcLine[srcY];
          l:=srcX shl 2;//4倍

          // 点(srcX,srcY)の色を(dstX,dstY)へコピー
          pBit[k]:=pBit2[l];//B?
          inc(k);
          inc(l);
          pBit[k]:=pBit2[l];//G
          inc(k);
          inc(l);
          pBit[k]:=pBit2[l];//R?
          inc(k,2);
       end else inc(k,4);
     end;
   end;
   //コピーして開放
   srcBmp.Assign(dstBmp);
   dstBmp.Free;
end;



procedure ChangeTopBottom(BMP:TBitmap);
var
  x,y,i,a   :SmallInt;  //ビットマップのＸ軸、Ｙ軸
  PBit,pBit2:PByteArray;
  BMP2:TBitmap;
begin



  BMP2:=TBitmap.Create;
  BMP2.Width :=BMP.Width;
  BMP2.Height:=BMP.height;
  BMP.PixelFormat := pf24Bit;
  BMP2.PixelFormat := pf24Bit;


  //コントラスト強調処理
  for y := 0 to BMP.Height-1 do
  begin

    pBit:=BMP.ScanLine[y];
    pBit2:=BMP2.ScanLine[BMP.Height-1-y];
    i:=0;
    for x := 0 to (BMP.Width-1)*3 do begin

        pBit2[i]:=pBit[i];
        inc(i);

    end;
  end;

  BMP.Assign(BMP2);

  BMP2.Free;


end;

//バグってました。THANKS flymanさん,びいさん
procedure Mirror(BMP:TBitmap);
var
  i:SmallInt;  //ビットマップのＸ軸、Ｙ軸
  BMP2:TBitmap;
begin



  BMP2:=TBitmap.Create;
  BMP2.Width :=BMP.Width;
  BMP2.Height:=BMP.height;


  //for i:=0 to BMP.Width-1 do begin
  //    bitblt(BMP2.Canvas.handle,BMP.Width-1-i,0,1,BMP.Height,BMP.Canvas.Handle,i,0,SRCCOPY);
  //end;


  StretchBlt(BMP2.Canvas.Handle,0, 0, BMP2.Width, BMP2.Height,BMP.Canvas.Handle,BMP.Width-1, 0, -BMP.Width, BMP.Height,SRCCOPY);

  BMP.Assign(BMP2);

  BMP2.Free;


end;

//http://homepage1.nifty.com/beny/tips/dib06.html
procedure Gamma2(Bitmap: TBitmap; Value: Double);
//ガンマ補正
var
  X, Y,w: Integer;
  pLine: PByteArray;
  Table: array[Byte]of Byte;
begin
  if (Value < 0.75) or (Value = 2.2) or (Value > 3) then Exit;

  Bitmap.PixelFormat := pf24bit;
  { 変換テーブルの作成 }
  Value := Value / 2.2;
  for Y := 0 to 255 do
  begin
    X := Round(Power(Y / 255, Value) * 255);
    if X > 255 then X := 255 else if X < 0 then X := 0;
    Table[Y] := X;
  end;

  w:=(Bitmap.Width -1)*3;

  { ピクセルの変換処理 }
  for Y := 0 to Bitmap.Height -1 do
  begin
    pLine := Bitmap.ScanLine[Y];
    for X := 0 to w do
        pLine[x]:=Table[pLine[x]];
  end;

end;




procedure SuperTextOut_fly(Canvas:TCanvas; X,Y:Integer; bFont:TFont; Msg:String);
const
	G = 1.0;	{中心ドットを 1 としたときの周辺ドットの重み}
	n = 1;	{周囲nドットからサンプリング}
var
	x1,y1,x3,i,j:Integer;//ループ用
	Pr,Pg,Pb :Integer;//加算平均値
	BMP1,BMP2,BMP3 :TBitmap;
	Size     :TSize;
	PBit1,PBit2,PBit3: PByteArray;
	W,H      :Integer;
	mj       :Double;
	gc       :Double;
	Italic   :Integer;
begin
	// Italic体のために幅に余裕を見る
	if fsItalic in bFont.Style then Italic := Trunc(bFont.Size/3) else Italic := 0;
	//クリエイト
	BMP1:=TBitmap.Create;	{ベースとなる文字列}
	BMP2:=TBitmap.Create;	{マスク}
	BMP3:=TBitmap.Create;	{作成後のイメージ}
	try
		//設定を代入
		BMP1.Canvas.Font.Assign(bFont);
		BMP2.Canvas.Font.Assign(bFont);
		BMP3.Canvas.Font.Assign(bFont);

		Size := BMP1.Canvas.TextExtent(Msg);

		//幅の設定
		W := Size.cx;
		H := Size.cy+1;

		//サイズを確定
		BMP1.Width  := (W+n*2+2)+Italic;
		BMP1.Height := (H+n*2+2);
		BMP2.Width  := (W+n*2+2)+Italic;
		BMP2.Height := (H+n*2+2);
		BMP3.Width  := (W+n*2+2)+Italic;
		BMP3.Height := (H+n*2+2);

		BMP1.PixelFormat := pf24Bit;
		BMP2.PixelFormat := pf24Bit;
		BMP3.PixelFormat := pf24Bit;

		BitBlt(BMP1.Canvas.Handle,0,0,W+n*2+2+Italic,H+n*2+2,Canvas.Handle,X-n-1,Y-n-1,SRCCOPY);	{ベース}
		BitBlt(BMP3.Canvas.Handle,0,0,W+n*2+2+Italic,H+n*2+2,Canvas.Handle,X-n-1,Y-n-1,SRCCOPY);	{加工後用}

		//文字を描画
		BMP1.Canvas.Brush.Style:=bsClear;
		BMP1.Canvas.TextOut(n,n,Msg);

		BMP2.Canvas.Brush.Style:=bsClear;
		BMP2.Canvas.Font.Color:=clBlack;

		//マスクを書く
		for j:=1 to (n*2+1) do
		begin
			for i:=1 to (n*2+1) do
			begin
				BMP2.Canvas.TextOut(i,j,Msg);
			end;
		end;

		for y1:=1 to BMP3.Height-1 do
		begin
			//Ｙラインの取得
			PBit2:=BMP2.ScanLine[y1];
			PBit3:=BMP3.ScanLine[y1];

			mj := (n*2+1)*(n*2+1);
			gc := mj-G*(mj-1);

			for x1:=1 to BMP3.Width-1 do
			begin
				//ＲＧＢの取得
				If PBit2[x1*3]=0 then
				begin	{マスクされた部分}
					Pr:=0;
					Pg:=0;
					Pb:=0;

					for j:=-n to n do
					begin	{上下3行}
						PBit1 :=BMP1.ScanLine[y1+j];
						for i:=-n to n do
						begin
							x3:=(x1+i)*3;
							//読み込み
							if (i=0) and (j=0) then
							begin
								Pr:=Pr+Trunc(PBit1[x3] * gc);
								Pg:=Pg+Trunc(PBit1[x3+1] * gc);
								Pb:=Pb+Trunc(PBit1[x3+2] * gc);
							end
							else
							begin
								Pr:=Pr+Trunc(PBit1[x3] * G);
								Pg:=Pg+Trunc(PBit1[x3+1] * G);
								Pb:=Pb+Trunc(PBit1[x3+2] * G);
							end;
						end;
					end;
					//平均値を出す
					//書き込み
					PBit3[x3]  :=Trunc(Pr / mj);
					PBit3[x3+1]:=Trunc(Pg / mj);
					PBit3[x3+2]:=Trunc(Pb / mj);
				end;
			end;
		end;
		BitBlt(Canvas.Handle,X-n,Y-n,W+n*2+Italic,H+n*2,BMP3.Canvas.Handle,1,1,SRCCOPY);
	finally
		//解放
		BMP1.Free;
		BMP2.Free;
		BMP3.Free;
	end;
end;

procedure SuperTextOutAlpha_fly(Canvas:TCanvas; X,Y:Integer; bFont:TFont; Msg:String;iA:Byte);
const
	G = 1.0;	{中心ドットを 1 としたときの周辺ドットの重み}
	n = 1;	{周囲nドットからサンプリング}
var
	x1,y1,x3,i,j:Integer;//ループ用
	Pr,Pg,Pb :Integer;//加算平均値
	BMP1,BMP2,BMP3 :TBitmap;
	Size     :TSize;
	PBit1,PBit2,PBit3: PByteArray;
	W,H      :Integer;
	mj       :Double;
	gc       :Double;
	Italic   :Integer;
        iA2      :Byte;
begin

        iA2:=255-iA;

	// Italic体のために幅に余裕を見る
	if fsItalic in bFont.Style then Italic := Trunc(bFont.Size/3) else Italic := 0;
	//クリエイト
	BMP1:=TBitmap.Create;	{ベースとなる文字列}
	BMP2:=TBitmap.Create;	{マスク}
	BMP3:=TBitmap.Create;	{作成後のイメージ}
	try
		//設定を代入
		BMP1.Canvas.Font.Assign(bFont);
		BMP2.Canvas.Font.Assign(bFont);
		BMP3.Canvas.Font.Assign(bFont);

		Size := BMP1.Canvas.TextExtent(Msg);

		//幅の設定
		W := Size.cx;
		H := Size.cy+1;

		//サイズを確定
		BMP1.Width  := (W+n*2+2)+Italic;
		BMP1.Height := (H+n*2+2);
		BMP2.Width  := (W+n*2+2)+Italic;
		BMP2.Height := (H+n*2+2);
		BMP3.Width  := (W+n*2+2)+Italic;
		BMP3.Height := (H+n*2+2);

		BMP1.PixelFormat := pf24Bit;
		BMP2.PixelFormat := pf24Bit;
		BMP3.PixelFormat := pf24Bit;

		BitBlt(BMP1.Canvas.Handle,0,0,W+n*2+2+Italic,H+n*2+2,Canvas.Handle,X-n-1,Y-n-1,SRCCOPY);	{ベース}
		BitBlt(BMP3.Canvas.Handle,0,0,W+n*2+2+Italic,H+n*2+2,Canvas.Handle,X-n-1,Y-n-1,SRCCOPY);	{加工後用}

		//文字を描画
		BMP1.Canvas.Brush.Style:=bsClear;
		BMP1.Canvas.TextOut(n,n,Msg);

		BMP2.Canvas.Brush.Style:=bsClear;
		BMP2.Canvas.Font.Color:=clBlack;

		//マスクを書く
		for j:=1 to (n*2+1) do
		begin
			for i:=1 to (n*2+1) do
			begin
				BMP2.Canvas.TextOut(i,j,Msg);
			end;
		end;

		for y1:=1 to BMP3.Height-1 do
		begin
			//Ｙラインの取得
			PBit2:=BMP2.ScanLine[y1];
			PBit3:=BMP3.ScanLine[y1];

			mj := (n*2+1)*(n*2+1);
			gc := mj-G*(mj-1);

			for x1:=1 to BMP3.Width-1 do
			begin
				//ＲＧＢの取得
				If PBit2[x1*3]=0 then
				begin	{マスクされた部分}
					Pr:=0;
					Pg:=0;
					Pb:=0;

					for j:=-n to n do
					begin	{上下3行}
						PBit1 :=BMP1.ScanLine[y1+j];
						for i:=-n to n do
						begin
							x3:=(x1+i)*3;
							//読み込み
							if (i=0) and (j=0) then
							begin
								Pr:=Pr+Trunc(PBit1[x3] * gc);
								Pg:=Pg+Trunc(PBit1[x3+1] * gc);
								Pb:=Pb+Trunc(PBit1[x3+2] * gc);
							end
							else
							begin
								Pr:=Pr+Trunc(PBit1[x3] * G);
								Pg:=Pg+Trunc(PBit1[x3+1] * G);
								Pb:=Pb+Trunc(PBit1[x3+2] * G);
							end;
						end;
					end;
					//平均値を出す
					//書き込み
					PBit3[x3]:=(Trunc(Pr / mj)*iA+pBit3[x3]*iA2) shr 8;
                                        inc(x3);
					PBit3[x3]:=(Trunc(Pg / mj)*iA+pBit3[x3]*iA2) shr 8;
                                        inc(x3);
					PBit3[x3]:=(Trunc(Pb / mj)*iA+pBit3[x3]*iA2) shr 8;
				end;
			end;
		end;
		BitBlt(Canvas.Handle,X-n,Y-n,W+n*2+Italic,H+n*2,BMP3.Canvas.Handle,1,1,SRCCOPY);
	finally
		//解放
		BMP1.Free;
		BMP2.Free;
		BMP3.Free;
	end;
end;




//ビットマップ暗号化エンジン
procedure XorBitmap(BMP:TBitmap;XORPass:String);
var x,x3,y,w,i,l:Integer;
    pBit:PByteArray;
    chr :PChar;
begin

  BMP.PixelFormat:=pf24Bit;
  //初期化
  w:=BMP.Width*3-3;

  //パスワードの再設定
  chr:=PChar(XorPass);
  l:=Length(Xorpass)-1;


  for y:=0 to BMP.Height-1 do begin
      pBit:=BMP.ScanLine[y];

      i:=y mod l;

      for x:=0 to W do begin
          //暗号処理
          pBit[x]:=pBit[x] xor Ord(chr[i mod l]);

          inc(i);
      end;
  end;

end;


//またパクりました。すみません。
//THANKS -> http://homepage1.nifty.com/beny/tips/dib16.html
procedure Mozaic(Bitmap: TBitmap; WSize, HSize: Integer; Clip: TRect);
var
  X, Y, I, J: Integer;
  xR, xG, xB, XX, YY: Integer;
  Cnt, BlockW, BlockH: Integer;
  pSrcCache: PCacheLines;
  pSrcLine: PLine24;
begin
 if ((WSize < 1) or (HSize < 1)) or ((WSize = 1) and (HSize = 1)) then Exit;

  { クリッピングエリアの最適化 }
  with Clip do begin
    if (Left = Right) or (Top = Bottom) then Exit;
    if Left > Right then  begin
      I     := Left;
      Left  := Right;
      Right := I;
    end;

    if Top > Bottom then begin
      I      := Top;
      Top    := Bottom;
      Bottom := I;
    end;
    
    if Left < 0 then Left := 0;
    if Top  < 0 then Top  := 0;
    if Right  >= Bitmap.Width  then Right  := Bitmap.Width;
    if Bottom >= Bitmap.Height then Bottom := Bitmap.Height;

    { ブロック数を計算する }
    BlockW := (Right - Left) div WSize;
    BlockH := (Bottom - Top) div HSize;
  end;

  Bitmap.PixelFormat := pf24bit;
  pSrcCache := GetCacheLines(Bitmap);//全ラインのキャッシュ
  try
    for Y := 0 to BlockH do
    begin
      YY := Y * HSize + Clip.Top;
      for X := 0 to BlockW do
      begin
        XX := X * WSize + Clip.Left;
        xR := 0;
        xG := 0;
        xB := 0;
        Cnt := 0;
        { ピクセルを切り出して輝度を加算する }
        for I := YY to YY+HSize -1 do
        begin
          if I >= Clip.Bottom then Continue;
          pSrcLine := pSrcCache^[I];
          for J := XX to XX+WSize -1 do
          begin
            if J >= Clip.Right then Continue;
            with pSrcLine^[J] do
            begin
              Inc(xB, B);
              Inc(xG, G);
              Inc(xR, R);
            end;
            Inc(Cnt);
          end;
        end;
        if Cnt = 0 then Continue;

        { 平均を計算 }
        xR := RoundByte(Round(xR / Cnt + 0.5));
        xG := RoundByte(Round(xG / Cnt + 0.5));
        xB := RoundByte(Round(xB / Cnt + 0.5));

        { ブロックの塗り潰し }
        for I := YY to YY+HSize -1 do
        begin
          if I >= Clip.Bottom then Continue;
          pSrcLine := pSrcCache^[I];
          for J := XX to XX+WSize -1 do
          begin
            if J >= Clip.Right then Continue;
            with pSrcLine^[J] do
            begin
              B := xB;
              G := xG;
              R := xR;
            end;
          end;
        end;
      end;
    end;
  finally
    FreeMem(pSrcCache);
  end;
end;

function GetCacheLines(Source: TBitmap): PCacheLines;
// ビットマップのスキャンラインをキャッシュする
var
  Y: Integer;
begin
  with Source do begin
    GetMem(Result, SizeOf(Pointer) * Height);
    try
      for Y := 0 to Height -1 do
        Result^[Y] := ScanLine[Y];
    except
      FreeMem(Result);
      raise;
    end;
  end;
end;

procedure Convert24Ato32(BMP24,ABMP,out32BMP:TBitmap);
var
   pb1,pb2,pb3:PByteArray;
   x,y,i,j,k:Integer;
begin

   Out32BMP.Width:=BMP24.Width;
   Out32BMP.Height:=BMP24.Height;

   Out32BMP.PixelFormat:=pf32Bit;
   BMP24.PixelFormat:=pf32Bit;
   ABMP.PixelFormat :=pf24Bit;



   for y:=0 to Out32BMP.Height-1 do begin
       pb1:=BMP24.Scanline[y];
       pb2:=ABMP.Scanline[y];
       pb3:=out32BMP.Scanline[y];
       i:=0;j:=0;k:=0;


       for x:=0 to Out32BMP.Width-1 do begin
           pb3[i]:=pb1[i];
           inc(i);
           pb3[i]:=pb1[i];
           inc(i);
           pb3[i]:=pb1[i];
           inc(i);
           pb3[i]:=pb2[j];
           inc(i);
           inc(j,3);
        end;
    end;

end;


//８ビットビットマップにパレットを無視して代入する荒技。
procedure Convert24Ato8(in24BMP,out8BMP:TBitmap);
var x,y,i:Integer;
    pBit,pBit2:PByteArray;
begin

out8BMP.Width :=in24BMP.Width;
out8BMP.Height:=in24BMP.Height;

in24BMP.Pixelformat:=pf24Bit;
out8BMP.PixelFOrmat:=pf8bit;

  for y:=0 to in24bmp.Height-1 do begin
      pBit:=in24bmp.ScanLine[y];
      pBit2:=out8BMP.ScanLine[y];
      
      i:=0;

      for x:=0 to in24bmp.Width-1 do begin
          pBit2[x]  :=pBit[i];
          inc(i,3);
      end;
  end;



end;
{$HINTS ON}


end.
