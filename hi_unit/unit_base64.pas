unit unit_base64;

interface

uses
  SysUtils;

function EncodeBase64R( const input: string; Rcode: string ): string;
function EncodeBase64( const input: string ): string;
function DecodeBase64( const input: string ): string;

implementation

const
  Code64: PChar = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

{Base64 デコード: 98/11/23}
function DecodeBase64( const input: string ): string;
var
  i,j,k,iLen: Integer;
  dbuf: array[0..3] of BYTE;
begin

  iLen := Length( input );
  Result := '';

  //デコード後の大きさを計算
  j := 0;
  for i:=1 to iLen do begin
    if (input[i] = #$0D) or (input[i] = #$0A) or (input[i] = '=') then
      Inc(j);
  end;
  iLen := iLen -j;
  i :=  iLen mod 4;
  if i <> 0 then Dec(i);
  iLen := (iLen div 4) * 3 +i;
  SetLength( Result, iLen); //高速化のため

  iLen := Length(input);
  i := 1;
  k := 1;
  while i <= iLen do begin
    if (input[i] = #$0D) or (input[i] = #$0A) then begin
      Inc(i);
      Continue;
    end;
    for j:=0 to 3 do begin
      case (input[i]) of
        'A'..'Z': dbuf[j] := BYTE(input[i]) - $41;
        'a'..'z': dbuf[j] := BYTE(input[i]) - $47;
        '0'..'9': dbuf[j] := BYTE(input[i]) + 4;
        '+'     : dbuf[j] := 62;
        '/'     : dbuf[j] := 63;
        '='     : dbuf[j] := $FF;
      end;
      Inc(i);
    end;

    if dbuf[2] = $FF then begin
      Result[k] := Char( (dbuf[0] shl 2) or (dbuf[1] shr 4) );
    end
    else if dbuf[3] = $FF then begin
      Result[k] := Char( (dbuf[0] shl 2) or (dbuf[1] shr 4) ); Inc(k);
      Result[k] := Char( (dbuf[1] shl 4) or (dbuf[2] shr 2) );
    end
    else begin
      Result[k] := Char( (dbuf[0] shl 2) or (dbuf[1] shr 4) ); Inc(k);
      Result[k] := Char( (dbuf[1] shl 4) or (dbuf[2] shr 2) ); Inc(k);
      Result[k] := Char( (dbuf[2] shl 6) or dbuf[3] );
    end;
    Inc(k);
  end;
end;


{Base64 エンコード。77文字以上の改行規則に未対応 :98/08/21}
{98/11/25: テーブル形式の変更に併せて修正。string -> PChar により Code64 }
{          が Zero origin に。}
function EncodeBase64( const input: string ): string;
var
  i,j,iLen: Integer;
  a,b,c: BYTE;
begin
  Result := '';

  //エンコード後の大きさを計算
  iLen := Length(input);
  i := iLen mod 3;
  if i <> 0 then i := 4;
  SetLength( Result, ( iLen div 3 ) * 4 + i);

  i:=1; j:=1;
  while i <= iLen -2 do begin
    a := BYTE(input[i]); b:= BYTE(input[i+1]); c := BYTE(input[i+2]);
    Result[j] := Code64[ ((a and $FC) shr 2) ]; Inc(j);
    Result[j] := Code64[ ( ((a and $03) shl 4) or ((b and $F0) shr 4) ) ]; Inc(j);
    Result[j] := Code64[ ( ((b and $0F) shl 2) or ((c and $C0) shr 6) ) ]; Inc(j);
    Result[j] := Code64[ (c and $3F) ]; Inc(j);
    i := i + 3;
  end;
  if (iLen mod 3) = 1 then begin
    a := BYTE(input[iLen]); b:=0;
    Result[j] := Code64[ ((a and $FC) shr 2) ]; Inc(j);
    Result[j] := Code64[ ( ((a and $03) shl 4) or ((b and $F0) shr 4) ) ]; Inc(j);
    Result[j] := '='; Inc(j);
    Result[j] := '=';
  end
  else if (iLen mod 3) = 2 then begin
    a := BYTE(input[iLen -1]); b := BYTE(input[iLen]); c := 0;
    Result[j] := Code64[ ((a and $FC) shr 2) ]; Inc(j);
    Result[j] := Code64[ ( ((a and $03) shl 4) or ((b and $F0) shr 4) ) ]; Inc(j);
    Result[j] := Code64[ ( ((b and $0F) shl 2) or ((c and $C0) shr 6) ) ]; Inc(j);
    Result[j] := '=';
  end;
end;


{Base64 エンコード。77文字以上の改行規則に対応 :98/11/23}
{Rcode には任意の改行コードをセット。ex #$0D#0A}
{98/11/25: テーブル形式の変更に併せて修正。string -> PChar により Code64 }
{          が Zero origin に。}
function EncodeBase64R( const input: string; Rcode: string ): string;
var
  i,j,k,l,iLen: Integer;
  a,b,c: BYTE;
begin
  Result := '';

  //エンコード後の大きさを計算
  iLen := Length(input);
  i := iLen mod 3;
  if i <> 0 then i := 4;
  i := i + ((( iLen div 3 ) * 4) div 76) * Length(Rcode);
  SetLength( Result, ( iLen div 3 ) * 4 + i);

  i:=1; j:=1; k:=0;
  while i <= iLen -2 do begin
    a := BYTE(input[i]); b:= BYTE(input[i+1]); c := BYTE(input[i+2]);
    Result[j] := Code64[ ((a and $FC) shr 2) ]; Inc(j);
    Result[j] := Code64[ ( ((a and $03) shl 4) or ((b and $F0) shr 4) ) ]; Inc(j);
    Result[j] := Code64[ ( ((b and $0F) shl 2) or ((c and $C0) shr 6) ) ]; Inc(j);
    Result[j] := Code64[ (c and $3F) ]; Inc(j);
    i := i + 3;
    k := k + 4;
    if k = 76 then begin
      for l:=1 to Length(Rcode) do begin
        Result[j] := Rcode[l]; Inc(j);
      end;
      k := 0;
    end;
  end;
  if (iLen mod 3) = 1 then begin
    a := BYTE(input[iLen]); b:=0;
    Result[j] := Code64[ ((a and $FC) shr 2) ]; Inc(j);
    Result[j] := Code64[ ( ((a and $03) shl 4) or ((b and $F0) shr 4) ) ]; Inc(j);
    Result[j] := '='; Inc(j);
    Result[j] := '=';
  end
  else if (iLen mod 3) = 2 then begin
    a := BYTE(input[iLen -1]); b := BYTE(input[iLen]); c := 0;
    Result[j] := Code64[ ((a and $FC) shr 2) ]; Inc(j);
    Result[j] := Code64[ ( ((a and $03) shl 4) or ((b and $F0) shr 4) ) ]; Inc(j);
    Result[j] := Code64[ ( ((b and $0F) shl 2) or ((c and $C0) shr 6) ) ]; Inc(j);
    Result[j] := '=';
  end;
end;

end.
