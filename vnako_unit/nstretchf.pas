unit nstretchf;
// しーやん様の提供(http://hp.vector.co.jp/authors/VA015850/)

interface
uses Windows, SysUtils, Graphics;

type
  TByteTriple = packed array[0..2] of Byte;
  TByteTripleArray = array[0..400000] of TByteTriple;
  PByteTripleArray = ^TByteTripleArray;

  TProgressProc = procedure(Progress: Integer);

  procedure Stretch(Src: TBitmap; Width, Height: Integer; PProc: TProgressProc); overload;
  procedure Stretch(Src: TBitmap; Width, Height: Integer); overload;
  procedure StretchAspect(BMP:TBitmap; w2, h2:Integer; PProc: TProgressProc); // アスペクト比を保ったままリサイズ
  procedure StretchAspectSpeed(BMP:TBitmap; w2, h2:Integer; PProc: TProgressProc); // アスペクト比を保ったままリサイズ(高速バージョン)
  procedure StretchAspect2(BMP:TBitmap; var w2, h2:Integer; PProc: TProgressProc); // アスペクト比を保ったままでw2,h2に指定した最大幅を使う
  procedure StretchAspect3(BMP:TBitmap; w2, h2:Integer; PProc: TProgressProc; bgcolor:Integer = 0); // アスペクト比を保ったままでw2,h2に指定した最大幅を使う


implementation

var
  Counter: Cardinal = 0;

const
  Interval = 50;

procedure StretchAspect2(BMP:TBitmap; var w2, h2:Integer; PProc: TProgressProc);
var
  tmp:TBitmap;
  T,L,W,H:Integer;
  r: Extended;
begin

  T:=0;
  L:=0;

  if BMP.Width*h2 > BMP.Height*w2 then begin
      W := w2;
      r := w2 / BMP.Width;
      H := Trunc( r * BMP.Height);
  end else begin
      H := h2;
      r := h2 / BMP.Height;
      W := Trunc( r * BMP.Width);
  end;
  w2 := W;
  h2 := H;

  tmp := TBitmap.Create ;
  try

    tmp.Assign(BMP);
    Stretch( tmp, W, H, PProc );

    BMP.Assign(nil);
    BMP.Width  := W;
    BMP.Height := H;
    BMP.Canvas.Draw(L,T,tmp);

  finally
    tmp.Free ;
  end;
end;

procedure StretchAspect3(BMP:TBitmap; w2, h2:Integer; PProc: TProgressProc; bgcolor:Integer = 0);
var
  tmp:TBitmap;
  T,L,W,H:Integer;
  r: Extended;
begin

  if BMP.Width*h2 > BMP.Height*w2 then begin
      W := w2;
      r := w2 / BMP.Width;
      H := Trunc( r * BMP.Height);
  end else begin
      H := h2;
      r := h2 / BMP.Height;
      W := Trunc( r * BMP.Width);
  end;

  tmp := TBitmap.Create ;
  try

    tmp.Assign(BMP);
    Stretch( tmp, W, H, PProc );

    BMP.Assign(nil);
    BMP.Width  := W2;
    BMP.Height := H2;
    with BMP.Canvas do
    begin
      Pen.Style := psSolid;
      Brush.Style := bsSolid;
      Brush.Color := bgcolor;
      Pen.Color := bgcolor;
      Rectangle(0,0,W2,H2);
    end;
    L := (W2 - W) div 2;
    T := (H2 - H) div 2;
    BMP.Canvas.Draw(L,T,tmp);

  finally
    tmp.Free ;
  end;
end;


procedure StretchAspect(BMP:TBitmap; w2, h2:Integer; PProc: TProgressProc);
var
  tmp:TBitmap;
  T,L,W,H:Integer;
begin

  T:=0;
  L:=0;

  if BMP.Width*h2 > BMP.Height*w2 then begin
      W:=W2;
      H:=W2*BMP.Height div BMP.Width;
      T:=(h2-H) div 2;
  end else begin
      H:=H2;
      W:=H2*BMP.Width div BMP.Height;
      L:=(w2-W) div 2;
  end;

  tmp := TBitmap.Create ;
  try

    tmp.Assign(BMP);
    Stretch( tmp, W, H, PProc );

    BMP.Assign(nil);
    BMP.Width :=W2;
    BMP.Height:=H2;
    BMP.Canvas.Draw(L,T,tmp);

  finally
    tmp.Free ;
  end;
end;

procedure StretchAspectSpeed(BMP:TBitmap; w2, h2:Integer; PProc: TProgressProc); // アスペクト比を保ったままリサイズ(高速バージョン)
var
  tmp:TBitmap;
  T,L,W,H:Integer;
  r: TRect;
begin
  T:=0;
  L:=0;

  if BMP.Width*h2 > BMP.Height*w2 then begin
      W:=W2;
      H:=W2*BMP.Height div BMP.Width;
      T:=(h2-H) div 2;
  end else begin
      H:=H2;
      W:=H2*BMP.Width div BMP.Height;
      L:=(w2-W) div 2;
  end;

  BMP.PixelFormat := pf24bit;
  tmp := TBitmap.Create ;
  try
    tmp.Width  := W;
    tmp.Height := H;
    tmp.PixelFormat := pf24bit;

    // copy
    r.Left := 0; r.Top := 0; r.Right := W; r.Bottom := H;
    tmp.Canvas.StretchDraw(r, BMP);

    BMP.Assign(nil);
    BMP.Width :=W2;
    BMP.Height:=H2;
    BMP.Canvas.Draw(L, T, tmp);

  finally
    tmp.Free ;
  end;
end;


procedure ProgressProcCaller(Progress: Integer; PProc: TProgressProc);
begin
  if not Assigned(PProc) then Exit;

  if Progress = 0 then
  begin
    Counter := GetTickCount;
    Exit;
  end;

  if GetTickCount - Counter < Interval then Exit;

  PProc(Progress);
  Counter := GetTickCount;
end;

procedure LI3(var LT: array of Integer; X: Extended; N: Integer);
begin
  LT[0] := Trunc((X - 1) * (X - 2) * (X - 3) * (1 / -6) * N + 0.5);
  LT[1] := Trunc((X - 0) * (X - 2) * (X - 3) * (1 /  2) * N + 0.5);
  LT[2] := Trunc((X - 0) * (X - 1) * (X - 3) * (1 / -2) * N + 0.5);
  LT[3] := Trunc((X - 0) * (X - 1) * (X - 2) * (1 /  6) * N + 0.5);
end;

procedure HLI3(Src, Dst: TBitmap; PProc: TProgressProc);
const
  PF = 20;
  PV = 1 shl PF;
var
  SP, DP: PByteTripleArray;
  SPT, DPT: array of PByteTripleArray;
  X, Y, I, M, N, W, TX, V: Integer;
  LT: array[0..3] of Integer;
  Z: Extended;
begin
  ProgressProcCaller(0, PProc);
  W := Src.Width - 1;
  SetLength(SPT, Src.Height);
  for Y := 0 to Src.Height - 1 do SPT[Y] := Src.Scanline[Y];
  SetLength(DPT, Dst.Height);
  for Y := 0 to Dst.Height - 1 do DPT[Y] := Dst.Scanline[Y];
  for X := 0 to Dst.Width - 1 do
  begin
    Z := X * (Src.Width - 1) / (Dst.Width - 1);
    TX := Trunc(Z) - 1;
    LI3(LT, Frac(Z) + 1, PV);

    if (TX < 0) or (3 + TX > W) then
    begin
      for Y := 0 to Dst.Height - 1 do
      begin
        SP := SPT[Y];
        DP := DPT[Y];
        for I := 0 to 2 do
        begin
          V := PV shr 1;
          for N := 0 to 3 do
          begin
            if N + TX < 0 then M := 0 else if N + TX > W then M := W
            else M := N + TX;
            V := V + LT[N] * SP[M][I];
          end;
          if V < 0 then V := 0 else if V > 255 shl PF then V := 255 shl PF;
          DP[X][I] := V shr PF;
        end;
      end
    end
    else
    begin
      for Y := 0 to Dst.Height - 1 do
      begin
        SP := SPT[Y];
        DP := DPT[Y];
        V := PV shr 1;
        Inc(V, LT[0] * SP[0+ TX][0]);
        Inc(V, LT[1] * SP[1+ TX][0]);
        Inc(V, LT[2] * SP[2+ TX][0]);
        Inc(V, LT[3] * SP[3+ TX][0]);
        if V < 0 then DP[X][0] := 0 else if V > 255 shl PF then DP[X][0] := 255
        else DP[X][0] := V shr PF;
        V := PV shr 1;
        Inc(V, LT[0] * SP[0 + TX][1]);
        Inc(V, LT[1] * SP[1 + TX][1]);
        Inc(V, LT[2] * SP[2 + TX][1]);
        Inc(V, LT[3] * SP[3 + TX][1]);
        if V < 0 then DP[X][1] := 0 else if V > 255 shl PF then DP[X][1] := 255
        else DP[X][1] := V shr PF;
        V := PV shr 1;
        Inc(V, LT[0] * SP[0 + TX][2]);
        Inc(V, LT[1] * SP[1 + TX][2]);
        Inc(V, LT[2] * SP[2 + TX][2]);
        Inc(V, LT[3] * SP[3 + TX][2]);
        if V < 0 then DP[X][2] := 0 else if V > 255 shl PF then DP[X][2] := 255
        else DP[X][2] := V shr PF;
      end
    end;
    ProgressProcCaller((100 * X) div ((Dst.Width - 1) * 2), PProc);
  end;
end;

procedure VLI3(Src, Dst: TBitmap; PProc: TProgressProc);
const
  PF = 20;
  PV = 1 shl PF;
var
  DP: PByteTripleArray;
  SPT: array of PByteTripleArray;
  X, Y, I, M, N, H, TY, V: Integer;
  LT: array[0..3] of Integer;
  Z: Extended;
begin
  ProgressProcCaller(50, PProc);
  H := Src.Height - 1;
  SetLength(SPT, Src.Height);
  for Y := 0 to Src.Height - 1 do SPT[Y] := Src.Scanline[Y];
  for Y := 0 to Dst.Height - 1 do
  begin
    Z := Y * (Src.Height - 1) / (Dst.Height - 1);
    TY := Trunc(Z) - 1;
    LI3(LT, Frac(Z) + 1, PV);
    DP := Dst.Scanline[Y];

    if (TY < 0) or (TY + 3 > H) then
    begin
      for X := 0 to Dst.Width - 1 do
      begin
        for I := 0 to 2 do
        begin
          V := PV shr 1;
          for N := 0 to 3 do
          begin
            if N + TY < 0 then M := 0 else if N + TY > H then M := H
            else M := N + TY;
            Inc(V, LT[N] * SPT[M][X][I]);
          end;
          if V < 0 then V := 0 else if V > 255 shl PF then V := 255 shl PF;
          DP[X][I] := V shr PF;
        end;
      end;
    end
    else
    begin
      for X := 0 to Dst.Width - 1 do
      begin
        V := PV shr 1;
        Inc(V, LT[0] * SPT[0 + TY][X][0]);
        Inc(V, LT[1] * SPT[1 + TY][X][0]);
        Inc(V, LT[2] * SPT[2 + TY][X][0]);
        Inc(V, LT[3] * SPT[3 + TY][X][0]);
        if V < 0 then DP[X][0] := 0 else if V > 255 shl PF then DP[X][0] := 255
        else DP[X][0] := V shr PF;
        V := PV shr 1;
        Inc(V, LT[0] * SPT[0 + TY][X][1]);
        Inc(V, LT[1] * SPT[1 + TY][X][1]);
        Inc(V, LT[2] * SPT[2 + TY][X][1]);
        Inc(V, LT[3] * SPT[3 + TY][X][1]);
        if V < 0 then DP[X][1] := 0 else if V > 255 shl PF then DP[X][1] := 255
        else DP[X][1] := V shr PF;
        V := PV shr 1;
        Inc(V, LT[0] * SPT[0 + TY][X][2]);
        Inc(V, LT[1] * SPT[1 + TY][X][2]);
        Inc(V, LT[2] * SPT[2 + TY][X][2]);
        Inc(V, LT[3] * SPT[3 + TY][X][2]);
        if V < 0 then DP[X][2] := 0 else if V > 255 shl PF then DP[X][2] := 255
        else DP[X][2] := V shr PF;
      end;
    end;
    ProgressProcCaller(50 + (100 * Y) div ((Dst.Height - 1) * 2), PProc);
  end;
end;

procedure HAO(Src, Dst: TBitmap; PProc: TProgressProc);
const
  PF1 = 18;
  PV1 = 1 shl PF1;
  PF2 = 22;
  PV2 = 1 shl PF2;
var
  SP, DP: PByteTripleArray;
  SPT, DPT: array of PByteTripleArray;
  X, Y: Integer;
  N, TR, TL, FR, FL, L, R, G, B: Cardinal;
  TT, FT: array of Cardinal;
  Z: Extended;
begin
  ProgressProcCaller(0, PProc);
  SetLength(SPT, Src.Height);
  for Y := 0 to Src.Height - 1 do SPT[Y] := Src.Scanline[Y];
  SetLength(DPT, Dst.Height);
  for Y := 0 to Dst.Height - 1 do DPT[Y] := Dst.Scanline[Y];
  L := Trunc((1 / (Src.Width / Dst.Width)) * PV2 + 0.5);

  SetLength(TT, Dst.Width + 1);
  SetLength(FT, Dst.Width + 1);
  for X := 0 to Dst.Width do
  begin
    Z := X * Src.Width / Dst.Width;
    TT[X] := Trunc(Z);
    FT[X] := Trunc(Frac(Z) * PV1 + 0.5);
  end;

  for Y := 0 to Dst.Height - 1 do
  begin
    SP := Src.ScanLine[Y];
    DP := Dst.ScanLine[Y];
    TR := 0;
    FR := 0;
    for X := 0 to Dst.Width - 1 do
    begin
      TL := TR;
      FL := PV1 - FR;
      TR := TT[X + 1];
      FR := FT[X + 1];

      B := PV1 shr 1;
      G := PV1 shr 1;
      R := PV1 shr 1;

      if FL <> 0 then
      begin
        Inc(B, SP[TL][0] * FL);
        Inc(G, SP[TL][1] * FL);
        Inc(R, SP[TL][2] * FL);
      end;

      for N := TL + 1 to TR - 1 do
      begin
        Inc(B, SP[N][0] shl PF1);
        Inc(G, SP[N][1] shl PF1);
        Inc(R, SP[N][2] shl PF1);
      end;

      if FR <> 0 then
      begin
        Inc(B, SP[TR][0] * FR);
        Inc(G, SP[TR][1] * FR);
        Inc(R, SP[TR][2] * FR);
      end;

      asm
        push edi
        mov ecx,X
        mov edi,DP
        mov eax,B
        lea ecx,[ecx+ecx*2]
        mul L
        mov eax,G
        mov [edi+ecx],dh
        mul L
        mov eax,R
        mov [edi+ecx+$1],dh
        mul L
        mov [edi+ecx+$2],dh
        pop edi
      end;
    end;
    ProgressProcCaller((100 * Y) div ((Dst.Height - 1) * 2), PProc);
  end;
end;

procedure VAO(Src, Dst: TBitmap; PProc: TProgressProc);
const
  PF1 = 18;
  PV1 = 1 shl PF1;
  PF2 = 22;
  PV2 = 1 shl PF2;
var
  X, Y: Integer;
  N, TR, TL, FR, FL, L: Cardinal;
  SPT: array of PByteTripleArray;
  B, G, R: array of Cardinal;
  DP, SP: PByteTripleArray;
  Z: Extended;
begin
  ProgressProcCaller(0, PProc);
  SetLength(SPT, Src.Height);
  for Y := 0 to Src.Height - 1 do SPT[Y] := Src.Scanline[Y];
  L := Trunc((1 / (Src.Height / Dst.Height)) * PV2 + 0.5);
  SetLength(B, Dst.Width);
  SetLength(G, Dst.Width);
  SetLength(R, Dst.Width);

  TR := 0;
  FR := 0;
  for Y := 0 to Dst.Height - 1 do
  begin
    DP := Dst.Scanline[Y];
    TL := TR;
    FL := PV1 - FR;
    Z := (Y + 1) * Src.Height / Dst.Height;
    TR := Trunc(Z);
    FR := Trunc(Frac(Z) * PV1 + 0.5);

    for X := 0 to Dst.Width - 1 do
    begin
      B[X] := PV1 shr 1;
      G[X] := PV1 shr 1;
      R[X] := PV1 shr 1;
    end;

    if FL <> 0 then
    begin
      SP := SPT[TL];
      for X := 0 to Dst.Width - 1 do
      begin
        Inc(B[X], SP[X][0] * FL);
        Inc(G[X], SP[X][1] * FL);
        Inc(R[X], SP[X][2] * FL);
      end;
    end;

    for N := TL + 1 to TR - 1 do
    begin
      SP := SPT[N];
      for X := 0 to Dst.Width - 1 do
      begin
        Inc(B[X], SP[X][0] shl PF1);
        Inc(G[X], SP[X][1] shl PF1);
        Inc(R[X], SP[X][2] shl PF1);
      end;
    end;

    if FR <> 0 then
    begin
      SP := SPT[TR];
      for X := 0 to Dst.Width - 1 do
      begin
        Inc(B[X], SP[X][0] * FR);
        Inc(G[X], SP[X][1] * FR);
        Inc(R[X], SP[X][2] * FR);
      end;
    end;

    X := Dst.Width;
    asm
      push esi
      push edi
      push ebx
      mov esi,X
      dec esi
      test esi,esi
      jl @loopend
      inc esi
      xor ecx,ecx
      @loopstart:
      push esi
      lea ebx,[ecx+ecx*2]
      mov esi,B
      mov edi,DP
      mov eax,[esi+ecx*4]
      mul L
      mov esi,G
      mov [edi+ebx],dh
      mov eax,[esi+ecx*4]
      mul L
      mov esi,R
      mov [edi+ebx+$1],dh
      mov eax,[esi+ecx*4]
      mul L
      mov [edi+ebx+$2],dh
      pop esi
      inc ecx
      dec esi
      jnz @loopstart
      @loopend:
      pop ebx
      pop edi
      pop esi
    end;

    ProgressProcCaller(50 + (100 * Y) div ((Dst.Height - 1) * 2), PProc);
  end;
end;

procedure Stretch(Src: TBitmap; Width, Height: Integer; PProc: TProgressProc);
var
  Dst: TBitmap;
begin
  if Width <= 8  then Width := 8;
  if Height <= 8 then Height := 8;
  
  if (Src = nil) or Src.Empty then Exit;
  if Src.PixelFormat <> pf24bit then
  begin
    Src.PixelFormat := pf24bit;
    Src.ReleasePalette;
  end;

  Dst := TBitmap.Create;
  try
    if Src.Width <> Width then
    begin
      Dst.Assign(Src);
      Dst.Width := Width;

      if Width > Src.Width then HLI3(Src, Dst, PProc)
      else HAO(Src, Dst, PProc);

      Src.Assign(Dst);
    end;

    if Src.Height <> Height then
    begin
      Dst.Assign(Src);
      Dst.Height := Height;

      if Height > Src.Height then VLI3(Src, Dst, PProc)
      else VAO(Src, Dst, PProc);

      Src.Assign(Dst);
    end;
  finally
    Dst.Free;
  end;
end;

procedure Stretch(Src: TBitmap; Width, Height: Integer);
begin
  Stretch(Src, Width, Height, nil);
end;

end.
