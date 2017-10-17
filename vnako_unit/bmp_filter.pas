unit bmp_filter;
// 説　明：画像にフィルターをかけるユニット／参考：http://homepage1.nifty.com/beny/delphi.html Rinka Kouzuki様
// 作　者：クジラ飛行机(http://kujirahand.com)
// 公開日：2001/10/21

interface
uses Windows, SysUtils, Classes, Graphics, forms;

type
  PRGB24 = ^TRGB24;
  TRGB24 = packed record
    B: Byte;
    G: Byte;
    R: Byte;
  end;

  TLine24 = array[0..MaxInt div SizeOf(TRGB24) -1]of TRGB24;
  PLine24 = ^TLine24;

  TCacheLines = array[0..MaxInt div SizeOf(Pointer) -1]of Pointer;
  PCacheLines = ^TCacheLines;

  TOperator3   = array[-1..1, -1..1]of Integer;
  TMatrix3     = array[-1..1, -1..1]of TRGB24;
  TLineMatrix3 = array[-1..1]of PLine24;

  TByteTable = array[Byte]of Byte;

  //関数
  function MakeOperator3(X: array of Integer): TOperator3;
  function GetCacheLines(Source: TBitmap): PCacheLines;
  procedure CopyDIB(Source, Dest: TBitmap);
  procedure StdTableFilter(Bitmap: TBitmap; Table: TByteTable);

  procedure NegaPosi(Bitmap: TBitmap);      // ネガポジ反転
  procedure Solarization(Bitmap: TBitmap);  // ソラリゼーション(ソラリゼーションは対象ピクセルの輝度を反転し、対象ピクセルと比較して輝度の低い方を取るフィルタです。
  procedure Grayscale(Bitmap: TBitmap);
  procedure Gamma(Bitmap: TBitmap; Value: Double);
  procedure Brightness(Bitmap: TBitmap; Value: Integer);

  procedure BmpColorChange(Bitmap: TBitmap; c1, c2: Integer);

  {画像を90度回転させます。左右を分けて書くのも面倒なので一つの関数にまとめました(どうせ垂直走査のループが違うだけだし)。特に説明は要らないでしょう。
  今まで定義だけして全く使わなかった GetCacheLines を初めて使用しました。この関数はビットマップの全スキャンラインをキャッシュする関数です。今回のように垂直走査と水平走査が置き換わるような場合、TBitmap.ScanLineを何度も呼び出すことになります。関数呼び出しは効率が悪いので、処理を行う前に全てのスキャンラインをキャッシュして関数の呼び出し回数を減らして高速化しています。}
  procedure Rotate90(Source: TBitmap; Right: Boolean);
  {画像を垂直方向に反転させます。作業用に同サイズの画像を用意してラインをコピーしていく方法でもいいのですが、ここでは一ライン分のバッファを用意してラインの入れ替えを行う方法を使います。}
  procedure VertReverse(Source: TBitmap);
  {画像を水平方向に反転させます。垂直反転と同じくバッファを使用するタイプです。といっても水平方向の反転はピクセル単位で処理しなければならないので、1ピクセル分のバッファで事足ります(^^;}
  procedure HorzReverse(Source: TBitmap);
  {画像を任意の角度で回転させます。}
  procedure RotateDraw(Canvas: TCanvas; iX, iY, iAngle: Integer;
    bmpSrc: TBitmap; clBackGround: TColor);

// 製作:1999/01/31、河邦 正（GCC02240@nifty.ne.jp）様：感謝
// フォームをビットマップに合わせて変形します
function CreateRgnFromBitmap(Src: TBitmap;
   TransparentColor: TColor): HRGN;
// ビットマップからリージョンを作成します
function SetRgnFromBitmap(Form: TForm; Bitmap: TBitmap;
  Repaint: Boolean = TRUE): Boolean;
// 吹き出し型にリージョンを作成します
function SetRgnHukidasi(Form: TForm; Repaint: Boolean = TRUE): Boolean;

implementation

uses Math, Types;

const
  EMes_InvalidGraphic = 'ビットマップが不正です。';


// ビットマップからリージョンを作成します
function CreateRgnFromBitmap(Src: TBitmap;
   TransparentColor: TColor): HRGN;
var
  Stream: TMemoryStream;
var
  Bitmap: TBitmap;
  pLine: PWORD;
  x, y, StartPos: Integer;
  R: TRect;
begin
  Result := HRGN(0);
  Bitmap := TBitmap.Create;
  try
    // 元のビットマップから複製を作ってマスク化します
    Bitmap.Assign(Src);
    if not Bitmap.Empty then
    begin
      Stream := TMemoryStream.Create;
      try
        Stream.SetSize(sizeof(TRGNDATAHEADER));
        with PRgnDataHeader(Stream.Memory)^ do
        begin
          dwSize := sizeof(TRGNDATAHEADER);
          iType := RDH_RECTANGLES;
          nCount := 0;
          nRgnSize := 0;
          rcBound := RECT(0, 0, Bitmap.Width, Bitmap.Height);
        end;
        Stream.Position := sizeof(TRGNDATAHEADER);

        // マスク（モノクロ）にします
        Bitmap.Mask(TransparentColor);

        // ScanLine からデータが取りやすいように 2bytes/pixel にします
        Bitmap.PixelFormat := pf15bit;

        for y := 0 to Bitmap.Height - 1 do
        begin
          pLine := Bitmap.ScanLine[y];
          StartPos := -1;
          for x := 0 to Bitmap.Width - 1 do
          begin
            if(StartPos < 0)and(pLine^ = 0)then
              StartPos := x;
            if(StartPos >= 0)then
            begin
              if(pLine^ <> 0)then
              begin
                R.Left := StartPos;
                R.Right := x;
                R.Top := y;
                R.Bottom := R.Top + 1;

                Stream.Write(R, sizeof(TRect));
                Inc(PRgnDataHeader(Stream.Memory)^.nCount);

                StartPos := -1;
              end
              else if x = (Bitmap.Width - 1)then
              begin
                R.Left := StartPos;
                R.Right := x + 1;
                R.Top := y;
                R.Bottom := R.Top + 1;

                // RECT を書き込むたびにメモリストリームのリサイズが
                // 行われるので、その分、非効率的ですが Delphi4 では
                // 実用スピードです（たぶん Delphi3 でも大丈夫）
                Stream.Write(R, sizeof(TRect));
                Inc(PRgnDataHeader(Stream.Memory)^.nCount);

                StartPos := -1;
              end;
            end;
            Inc(pLine);
          end;
        end; // for y := ...
        Result := ExtCreateRegion(nil, Stream.Size, 
                                  PRgnData(Stream.Memory)^);
        if Result = 0 then
          Result := CreateRectRgn(0, 0, Bitmap.Width, Bitmap.Height);
      finally
        Stream.Free;
      end;
    end;
  finally
    Bitmap.Free;
  end;
end;

// フォームをビットマップに合わせて変形します
function SetRgnFromBitmap(Form: TForm; Bitmap: TBitmap;
  Repaint: Boolean = TRUE): Boolean;
var
  hrgnNew: HRGN;
  R: TRect;
begin
  Result := FALSE;
  // ビットマップからリージョンを作って
  hrgnNew := CreateRgnFromBitmap(Bitmap, Bitmap.TransparentColor);
  if Integer(hrgnNew) = 0 then Exit;
  if GetRgnBox(hrgnNew, R) <> NULLREGION then
  begin
    // リージョンをクライアント領域にずらします
    if Form.Parent = nil then
      R.TopLeft := Form.ClientToScreen(Point(-Form.Left, -Form.Top))
    else
      R.TopLeft := Form.Parent.ScreenToClient(Form.ClientToScreen(Point(-Form.Left, -Form.Top)));
    OffsetRgn(hrgnNew, R.Left, R.Top);

    // リージョンをフォームに適用します
    Result := (SetWindowRgn(Form.Handle, hrgnNew, Repaint) <> 0);
  end
  else
  begin
    DeleteObject(hrgnNew);
  end;
end;

// 吹き出し型にリージョンを作成します
function SetRgnHukidasi(Form: TForm; Repaint: Boolean = TRUE): Boolean;
var
  hrgn1, hrgn2, hrgnNew: HRGN;
  PointArray: array[1..3]of TPoint;
  R: TRect;
begin
  Result := FALSE;
  // ●
  hrgn1 := CreateEllipticRgn(0,0,Form.ClientWidth, Form.ClientHeight);
  // 吹き出しの角
  PointArray[1] := Point(Trunc(Form.ClientWidth * 0.75), Trunc(Form.ClientHeight * 0.5));
  PointArray[2] := Point(Form.ClientWidth,  Form.ClientHeight);
  PointArray[3] := Point(Trunc(Form.ClientWidth * 0.5), Trunc(Form.ClientHeight * 0.75));
  hrgn2 := CreatePolygonRgn(PointArray, 3, ALTERNATE);
  // 合成
  hrgnNew := CreateRectRgn(0,0,9,9); // 適当なリージョンを作る
  CombineRgn(hrgnNew, hrgn1, hrgn2, RGN_OR);

  if Integer(hrgnNew) = 0 then Exit;
  if GetRgnBox(hrgnNew, R) <> NULLREGION then
  begin
    // リージョンをクライアント領域にずらします
    R.TopLeft := Form.ClientToScreen(Point(-Form.Left, -Form.Top));
    OffsetRgn(hrgnNew, R.Left, R.Top);

    // リージョンをフォームに適用します
    Result := (SetWindowRgn(Form.Handle, hrgnNew, Repaint) <> 0);
  end
  else
  begin
    DeleteObject(hrgnNew);
  end;
  DeleteObject(hrgn1);
  DeleteObject(hrgn2);
end;


procedure RotateDraw(Canvas: TCanvas; iX, iY, iAngle: Integer;
  bmpSrc: TBitmap; clBackGround: TColor);
//1997/10/25、河邦 正様の提供（GCC02240@niftyserve.or.jp）
var
  dwBackGround: DWORD;
  CosValue, SinValue: Extended;
  bmpTmp, bmpDst: TBitmap;
  x, y: Integer;
  exX, exY: Extended;
  pointTmp: TPoint;
  pdwDstLine: PDWORD;
begin
  // デフォルトの背景色をビットマップ内のフォーマットに変換する
  dwBackGround := (DWORD(clBackGround) and $ff shl 16)
               or (DWORD(clBackGround) and $ff00)
               or (DWORD(clBackGround) and $ff0000 shr 16);

  // 三角関数の計算結果をキープする
  CosValue := Cos(iAngle * Pi / 180);
  SinValue := Sin(iAngle * Pi / 180);

  bmpTmp := TBitmap.Create;
  try
    // ソースビットマップをコピーしてからフォーマットを pf32Bit にする
    bmpTmp.Assign(bmpSrc);
    bmpTmp.PixelFormat := pf32Bit;

    // 回転後の画像を入れるビットマップの作成
    bmpDst := TBitmap.Create;
    try
      bmpDst.PixelFormat := pf32Bit;

      // 回転後の画像が入る大きさにする
      bmpDst.Width  := Round(abs(CosValue * bmpTmp.Width)
                           + abs(-SinValue * bmpTmp.Height)) + 1;
      bmpDst.Height := Round(abs(SinValue * bmpTmp.Width)
                           + abs(CosValue * bmpTmp.Height)) + 1;

      // 回転コピー先のビットマップのスキャン開始点（0,0）のソースビット
      // マップ座標軸上での位置を計算して exX と exY に代入する
      pointTmp := Point(bmpDst.Width div 2, bmpDst.Height div 2);
      exX := (bmpTmp.Width  / 2) - (CosValue * pointTmp.x)
                                 - (SinValue * pointTmp.y);
      exY := (bmpTmp.Height / 2) - (-SinValue * pointTmp.x)
                                 - (CosValue * pointTmp.y);

      // スキャン開始
      for y := 0 to bmpDst.Height - 1 do
      begin
        pdwDstLine := bmpDst.ScanLine[y];
        for x := 0 to bmpDst.Width - 1 do
        begin
          pointTmp := Point(Round(exX), Round(exY));

          // exX & exY がソースビットマップの有効範囲である場合
          if(0 <= pointTmp.x)and(pointTmp.x < bmpTmp.Width)and
            (0 <= pointTmp.y)and(pointTmp.y < bmpTmp.Height)then
            pdwDstLine^ := PDWORD(PChar(bmpTmp.ScanLine[pointTmp.y])
                                       + (pointTmp.x * sizeof(DWORD)))^
          // exX & exY がソースビットマップの有効範囲外なら背景色にする
          else
            pdwDstLine^ := dwBackGround;

          // odwDstLine, exX & exY を次のピクセルに移す
          Inc(pdwDstLine);
          exX := exX + CosValue;
          exY := exY - SinValue;
        end;
        // exX & exY を次の行の先頭に戻す
        exX := exX + (SinValue - (CosValue * bmpDst.Width));
        exY := exY + (CosValue - (-SinValue * bmpDst.Width));
      end;
      // 回転したビットマップをキャンバスに描画する
      Canvas.Draw(iX, iY, bmpDst);
    finally
      bmpDst.Free;
    end;
  finally
    bmpTmp.Free;
  end;
end;


function MakeOperator3(X: array of Integer): TOperator3;
// オペレーターを作成
var
  I, MX, MY, Count: Integer;
begin
  FillChar(Result, SizeOf(Result), 0);
  Count := High(X);
  if Count = -1 then Exit;
  I := 0;
  for MX := -1 to 1 do
    for MY := -1 to 1 do
    begin
      Result[MX, MY] := X[I];
      Inc(I);
      if I > Count then Break;
    end;
end;

function GetCacheLines(Source: TBitmap): PCacheLines;
// ビットマップのスキャンラインをキャッシュする
var
  Y: Integer;
begin
  if (Source = nil) or Source.Empty then
    raise EInvalidGraphicOperation.Create(EMes_InvalidGraphic);
  with Source do
  begin
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

procedure CopyDIB(Source, Dest: TBitmap);
// DIBをコピーする
var
  Y, Bytes: Integer;
begin
  if (Source = nil) or Source.Empty or (Dest = nil) then
    raise EInvalidGraphicOperation.Create(EMes_InvalidGraphic);
  Source.PixelFormat := pf24bit;
  Dest.PixelFormat   := pf24bit;
  Dest.Width  := Source.Width;
  Dest.Height := Source.Height;
  Bytes := BytesPerScanline(Source.Width, 24, 32);
  for Y := 0 to Source.Height -1 do
    Move(Source.ScanLine[Y]^, Dest.ScanLine[Y]^, Bytes);
end;

procedure StdTableFilter(Bitmap: TBitmap; Table: TByteTable);
//単純なテーブル変換を行う関数
var
  X, Y: Integer;
  pLine: PLine24;
begin
  Bitmap.PixelFormat := pf24bit;

  { ピクセルの変換処理 }
  for Y := 0 to Bitmap.Height -1 do
  begin
    pLine := Bitmap.ScanLine[Y];
    for X := 0 to Bitmap.Width -1 do
      with pLine^[X] do
      begin
        R := Table[R];
        G := Table[G];
        B := Table[B];
      end;
  end;
end;

procedure NegaPosi(Bitmap: TBitmap);
// ネガポジ反転
var
  X, Y: Integer;
  pLine: PLine24;
begin
  Bitmap.PixelFormat := pf24bit;
  for Y := 0 to Bitmap.Height -1 do
  begin
    pLine := Bitmap.ScanLine[Y];
    for X := 0 to Bitmap.Width -1 do
      with pLine^[X] do
      begin
        R := R xor $FF;
        G := G xor $FF;
        B := B xor $FF;
      end;
  end;
  if Assigned(Bitmap.OnChange) then
    Bitmap.OnChange(Bitmap);
end;

procedure BmpColorChange(Bitmap: TBitmap; c1, c2: Integer);
var
  X, Y: Integer;
  C1R,C1G,C1B,C2R,C2G,C2B: Byte;
  pLine: PLine24;
begin
  C1R := (c1       ) and $FF;
  C1G := (c1 shr  8) and $FF;
  C1B := (c1 shr 16) and $FF;
  //
  C2R := (c2       ) and $FF;
  C2G := (c2 shr  8) and $FF;
  C2B := (c2 shr 16) and $FF;

  Bitmap.PixelFormat := pf24bit;
  for Y := 0 to Bitmap.Height -1 do
  begin
    pLine := Bitmap.ScanLine[Y];
    for X := 0 to Bitmap.Width -1 do
    begin
      with pLine^[X] do
      begin // RGB -> BGR
        if (R=C1R)and(G=C1G)and(B=C1B) then
        begin
          R := C2R;
          G := C2G;
          B := C2B;
        end;
      end;
    end;
  end;
  if Assigned(Bitmap.OnChange) then
    Bitmap.OnChange(Bitmap);
end;


procedure Solarization(Bitmap: TBitmap);
var
  X, Y: Integer;
  Table: TByteTable;
begin
  { 変換テーブルを生成 }
  for X := 0 to 255 do
  begin
    //Table[X] := Min(X, X xor $FF);
    Y := X xor $FF;
    if X < Y then Y := X;
    Table[X] := Y;
  end;

  //ピクセルの変換処理
  StdTableFilter(Bitmap, Table);

  if Assigned(Bitmap.OnChange) then
    Bitmap.OnChange(Bitmap);
end;

procedure Grayscale(Bitmap: TBitmap);
//グレイスケール
var
  X, Y, Gray: Integer;
  pLine: PLine24;
begin
  Bitmap.PixelFormat := pf24bit;
  { ピクセルの変換処理 }
  for Y := 0 to Bitmap.Height -1 do
  begin
    pLine := Bitmap.ScanLine[Y];
    for X := 0 to Bitmap.Width -1 do
      with pLine^[X] do
      begin
        Gray := Round((R * 30 + G * 59 + B * 11) / 100);
        { 0..255の範囲に飽和(もしかすると必要ないかも(^^;) }
        if Gray > 255 then Gray := 255
        else if Gray < 0 then Gray := 0;
        R := Gray;
        G := Gray;
        B := Gray;
      end;
  end;
  if Assigned(Bitmap.OnChange) then
    Bitmap.OnChange(Bitmap);
end;

procedure Gamma(Bitmap: TBitmap; Value: Double);
//ガンマ補正
var
  X, Y: Integer;
  Table: TByteTable;
begin
  { 変換テーブルの作成 }
  Value := Value / 2.2;
  for Y := 0 to 255 do
  begin
    X := Round(Power(Y / 255, Value) * 255);
    if X > 255 then X := 255 else if X < 0 then X := 0;
    Table[Y] := X;
  end;

  //ピクセルの変換処理
  StdTableFilter(Bitmap, Table);

  if Assigned(Bitmap.OnChange) then
    Bitmap.OnChange(Bitmap);
end;

procedure Brightness(Bitmap: TBitmap; Value: Integer);
//明るさ補正
var
  X, Y: Integer;
  Table: TByteTable;
begin
  if (Value = 0) or (Value > 255) or (Value < -255) then Exit;
  { 変換テーブルの作成 }
  for Y := 0 to 255 do
  begin
    X := Y + Value;
    if X > 255 then X := 255 else if X < 0 then X := 0;
    Table[Y] := X;
  end;

  //ピクセルの変換処理
  StdTableFilter(Bitmap, Table);

  if Assigned(Bitmap.OnChange) then
    Bitmap.OnChange(Bitmap);
end;



procedure HorzReverse(Source: TBitmap);
var
  X, Y, W: Integer;
  pLine: PLine24;
  Temp: TRGB24;
begin
  Source.PixelFormat := pf24bit;
  W := Source.Width -1;
  for Y := 0 to Source.Height -1 do
  begin
    pLine := Source.ScanLine[Y];
    for X := 0 to W div 2 do
    begin
      Temp := pLine^[X];
      pLine^[X]   := pLine^[W-X];
      pLine^[W-X] := Temp;
    end;
  end;
  if Assigned(Source.OnChange) then
    Source.OnChange(Source);
end;


procedure VertReverse(Source: TBitmap);
var
  Y, H, BufSize: Integer;
  pLine1, pLine2, pBuffer: Pointer;
begin
  Source.PixelFormat := pf24bit;
  BufSize := BytesPerScanline(Source.Width, 24, 32);
  H := Source.Height -1;
  GetMem(pBuffer, BufSize);
  try
    with Source do
      for Y := 0 to H div 2 do
      begin
        pLine1 := ScanLine[Y];
        pLine2 := ScanLine[H-Y];
        Move(pLine1^, pBuffer^, BufSize);
        Move(pLine2^, pLine1^, BufSize);
        Move(pBuffer^, pLine2^, BufSize);
      end;
  finally
    FreeMem(pBuffer);
  end;
  if Assigned(Source.OnChange) then
    Source.OnChange(Source);
end;



procedure Rotate90(Source: TBitmap; Right: Boolean);
var
  X, Y, W, H: Integer;
  Dest: TBitmap;
  pDstLine: PLine24;
  pSrcCache: PCacheLines;
begin
  W := Source.Width;
  H := Source.Height;
  Source.PixelFormat := pf24bit;
  Dest := TBitmap.Create;
  pSrcCache := GetCacheLines(Source);//全ラインのキャッシュ
  try
    Dest.PixelFormat := pf24bit;
    Dest.Width  := H;
    Dest.Height := W;
    Dec(W);
    Dec(H);
    for X := 0 to W do
    begin
      pDstLine := Dest.ScanLine[X];
      if Right then
      begin
      { 時計回り }
        for Y := 0 to H do
          pDstLine^[H-Y] := PLine24(pSrcCache^[Y])^[X];
      end else begin
      { 反時計回り }
        for Y := 0 to H do
          pDstLine^[Y] := PLine24(pSrcCache^[Y])^[W-X];
      end;
    end;
    Source.Assign(Dest);
  finally
    Dest.Free;
    FreeMem(pSrcCache);
  end;
end;

 

end.
