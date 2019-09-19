// ********************************************************************
//                   バーコード生成ユニット ver0.71
//
//                           Created  by DEKO
//                           Modified by M&I(ver0.30/0.40)
//
// ********************************************************************

unit barcode;

interface

uses
  SysUtils;

// JAN(EAN)/短縮
function Make_JAN(Barcode:String):String;
// CODE-39
function Make_CODE39(BarCode:String;CD:Boolean):String;
// NW-7(CODABAR)
function Make_NW7(BarCode:String;StartChar,StopChar:Char;CD:Boolean):String;
// ITF(Interleaved 2 of 5)
function Make_ITF(BarCode:String;CD:Boolean):String;
// カスタマーバーコード
function Make_Customer(BarCode:String):String;
// CODE-128
function Make_Code128(BarCode:String;StartCode:Char):String;

implementation

function Make_JAN(BarCode:String):String;
type
  CharData = array[0..9] of String[8];
var
  ChDCount,
  CodeType,
  pf      :Integer;
  i       ,
  j       ,
  k       :LongInt;
  Dmy     ,
  Module  :String;
  pt      ,
  ol      ,
  el      ,
  er      :CharData;
begin
  pt[0] := '111111';
  pt[1] := '110100';
  pt[2] := '110010';
  pt[3] := '110001';
  pt[4] := '101100';
  pt[5] := '100110';
  pt[6] := '100011';
  pt[7] := '101010';
  pt[8] := '101001';
  pt[9] := '100101';

  ol[0] := '0001101';
  ol[1] := '0011001';
  ol[2] := '0010011';
  ol[3] := '0111101';
  ol[4] := '0100011';
  ol[5] := '0110001';
  ol[6] := '0101111';
  ol[7] := '0111011';
  ol[8] := '0110111';
  ol[9] := '0001011';

  el[0] := '0100111';
  el[1] := '0110011';
  el[2] := '0011011';
  el[3] := '0100001';
  el[4] := '0011101';
  el[5] := '0111001';
  el[6] := '0000101';
  el[7] := '0010001';
  el[8] := '0001001';
  el[9] := '0010111';

  er[0] := '1110010';
  er[1] := '1100110';
  er[2] := '1101100';
  er[3] := '1000010';
  er[4] := '1011100';
  er[5] := '1001110';
  er[6] := '1010000';
  er[7] := '1000100';
  er[8] := '1001000';
  er[9] := '1110100';

  Dmy := BarCode;
  CodeType := Integer(Length(Dmy) > 8);
  case CodeType of
    0:Dmy := Copy(Dmy,1, 7);
    1:Dmy := Copy(Dmy,1,12);
  end;

  {チェックディジットの付加(自動生成) }
  // 2000/03/10 Update M&I From Here 
  j := 0;
  ChDCount := 1;
  for i:= Length(Dmy) downto 1 do
    begin
      if (ChDCount mod 2) = 1 then
       j := j + StrToInt(Dmy[i]) * 3
      else
       j := j + StrToInt(Dmy[i]);
      Inc(ChDCount);
    end;

  j := j mod 10;
  if j > 0 then
    j := 10 - j;
  // 2000/03/10 Update M&I Until Here 

  Dmy := Dmy + IntToStr(j);

  {バーコードの左側の作成}
  Module := '101';
  pf := StrToInt('0' + Dmy[1]);
  for i := (CodeType + 1) to (CodeType * 3 + 4) do
    begin
      k := StrToInt('0' + Dmy[i]);
      if (Copy(pt[pf],i-1,1) = '1') or (CodeType = 0) then
        Module := Module + ol[k]
      else
        Module := Module + el[k];
    end;

  {バーコードの中央の作成}
  Module := Module + '01010';

  {バーコードの右側の作成}
  for i:=(CodeType * 3 + 5) to (CodeType * 5 + 8) do
    begin
      k := StrToInt('0' + Dmy[i]);
      Module := Module + er[k]
    end;
  Module := Module + '1010';

  result := Module;
end;

function Make_CODE39(BarCode:String;CD:Boolean):String;
var
  i    :Integer;
  Check:LongInt;
  pm   ,
  tb   :String;
  bp   :array [$00..$2B] of String[10];
begin
  tb := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%*';
  bp[$00] := '1012303010'; // 0
  bp[$01] := '3012101030'; // 1
  bp[$02] := '1032101030'; // 2
  bp[$03] := '3032101010'; // 3
  bp[$04] := '1012301030'; // 4
  bp[$05] := '3012301010'; // 5
  bp[$06] := '1032301010'; // 6
  bp[$07] := '1012103030'; // 7
  bp[$08] := '3012103010'; // 8
  bp[$09] := '1032103010'; // 9
  bp[$0A] := '3010121030'; // A
  bp[$0B] := '1030121030'; // B
  bp[$0C] := '3030121010'; // C
  bp[$0D] := '1010321030'; // D
  bp[$0E] := '3010321010'; // E
  bp[$0F] := '1030321010'; // F
  bp[$10] := '1010123030'; // G
  bp[$11] := '3010123010'; // H
  bp[$12] := '1030123010'; // I
  bp[$13] := '1010323010'; // J
  bp[$14] := '3010101230'; // K
  bp[$15] := '1030101230'; // L
  bp[$16] := '3030101210'; // M
  bp[$17] := '1010301230'; // N
  bp[$18] := '3010301210'; // O
  bp[$19] := '1030301210'; // P
  bp[$1A] := '1010103230'; // Q
  bp[$1B] := '3010103210'; // R
  bp[$1C] := '1030103210'; // S
  bp[$1D] := '1010303210'; // T
  bp[$1E] := '3210101030'; // U
  bp[$1F] := '1230101030'; // V
  bp[$20] := '3230101010'; // W
  bp[$21] := '1210301030'; // X
  bp[$22] := '3210301010'; // Y
  bp[$23] := '1230301010'; // Z
  bp[$24] := '1210103030'; // -
  bp[$25] := '3210103010'; // .
  bp[$26] := '1230103010'; // [SPACE]
  bp[$27] := '1212121010'; // $
  bp[$28] := '1212101210'; // /
  bp[$29] := '1210121210'; // +
  bp[$2A] := '1012121210'; // %
  bp[$2B] := '1210303010'; // *

  {チェックディジットの算出}
  Check := 0;
  if CD then
    begin
      // すべての文字を与えられたコードに当てはめて加算
      for i:=1 to Length(BarCode) do
//      Check := Check + Pos(Barcode[i],tb);      // 2000/02/21 Delete DEKO
        Check := Check + Pos(Barcode[i],tb) - 1;  // 2000/02/21 Modify M&I
      // モジュラス４３でチェックデジットを算出
      Check := Check mod 43;
    end;

  {バーコードの作成}
  pm := '';
  pm := pm + bp[$2B];                      // スタートキャラクタを'*'追加
  for i:=1 to Length(BarCode) do
    pm := pm + bp[Pos(BarCode[i],tb)-1];
  if CD then                               // チェックディジットを追加
    pm := pm + bp[Check];
  pm := pm + bp[$2B];                      // ストップキャラクタ'*'を追加

  result := pm;
end;

function Make_NW7(BarCode:String;StartChar,StopChar:Char;CD:Boolean):String;
var
  i    :Integer;
  Check:LongInt;
  pm   ,
  tb   :String;
  bp   :array [$00..$13] of String[8];
begin
  tb := '0123456789-$:/.+ABCD';
  bp[$00] := '10101230'; // 0
  bp[$01] := '10103210'; // 1
  bp[$02] := '10121030'; // 2
  bp[$03] := '32101010'; // 3
  bp[$04] := '10301210'; // 4
  bp[$05] := '30101210'; // 5
  bp[$06] := '12101030'; // 6
  bp[$07] := '12103010'; // 7
  bp[$08] := '12301010'; // 8
  bp[$09] := '30121010'; // 9
  bp[$0A] := '10123010'; // -
  bp[$0B] := '10321010'; // $
  bp[$0C] := '30103030'; // :
  bp[$0D] := '30301030'; // /
  bp[$0E] := '30303010'; // .
  bp[$0F] := '10303030'; // +
  bp[$10] := '10321210'; // A
  bp[$11] := '12121030'; // B
  bp[$12] := '10121230'; // C
  bp[$13] := '10123210'; // D

  {チェックディジットの算出}
  Check := 0;
  if CD then
    begin
      // すべての文字を与えられたコードに当てはめて加算
      for i:=1 to Length(BarCode) do
//      Check := Check + Pos(Barcode[i],tb);      // 2000/02/21 Delete DEKO
        Check := Check + Pos(Barcode[i],tb) - 1;  // 2000/02/21 Modify M&I
      // モジュラス16でチェックデジットを算出
      if (Check mod 16) = 0 then
        Check := 0
      else
        Check := 16 - (Check mod 16);
    end;

  {バーコードの作成}
  pm := '';
  pm := pm + bp[Pos(StartChar,tb)-1];      // スタートキャラクタを追加
  for i:=1 to Length(BarCode) do
    pm := pm + bp[Pos(BarCode[i],tb)-1];
  if CD then                               // チェックディジットを追加
    pm := pm + bp[Check];
  pm := pm + bp[Pos(StopChar,tb)-1];       // ストップキャラクタを追加

  result := pm;
end;

// 2of5系のバーコードを追加する場合を考えて分離してあります。
//
// ・Industrial 2of5
// ・IATA(International Air Transport Assosiation) 2of5
// ・Matrix 2of5
// ・COOP 2of5
// ...等々

function Make_TF(BarCode:String;BType:Byte;CD:Boolean):String;
type
  CharData = array[0..9] of String[10];
var
//len,
  Check,
  ChDCount:Integer;
  i       ,
  j	  ,
  k       :LongInt;
  Dmy     ,
  ocd	  ,
  ecd	  ,
  Module  :String;
  oc      ,
  ec      :CharData;
  se      :array[0..1] of String;
begin
  Result := '';

  oc[0] := '1 1 3 3 1 ';
  oc[1] := '3 1 1 1 3 ';
  oc[2] := '1 3 1 1 3 ';
  oc[3] := '3 3 1 1 1 ';
  oc[4] := '1 1 3 1 3 ';
  oc[5] := '3 1 3 1 1 ';
  oc[6] := '1 3 3 1 1 ';
  oc[7] := '1 1 1 3 3 ';
  oc[8] := '3 1 1 3 1 ';
  oc[9] := '1 3 1 3 1 ';

  ec[0] := '0 0 2 2 0';
  ec[1] := '2 0 0 0 2';
  ec[2] := '0 2 0 0 2';
  ec[3] := '2 2 0 0 0';
  ec[4] := '0 0 2 0 2';
  ec[5] := '2 0 2 0 0';
  ec[6] := '0 2 2 0 0';
  ec[7] := '0 0 0 2 2';
  ec[8] := '2 0 0 2 0';
  ec[9] := '0 2 0 2 0';

  se[0] := '1010';
  se[1] := '301';
  Dmy := BarCode;

  {チェックディジットの付加 }
  if CD then
    begin
      Check := 0;
      ChDCount := 1;
      for i:= Length(BarCode) downto 1 do
        begin
          if (ChDCount mod 2) = 1 then
            Check := Check + StrToInt(Barcode[i]) * 3
          else
            Check := Check + StrToInt(Barcode[i]);
          Inc(ChDCount);
        end;
      // モジュラス１０でチェックデジットを算出
      Check := Check mod 10;
      // 0の場合はそのまま
      if Check > 0 then
        Check := 10 - Check;

      Dmy := Dmy + IntToStr(Check);
    end;
    
  Module := se[0];
  for i := 0 to Length(Dmy) div 2 - 1 do
    begin
      // 奇数
      k := StrToInt('0' + Dmy[i * 2 + 1]);
      ocd := oc[k];
      // 偶数
      k := StrToInt('0' + Dmy[i * 2 + 2]);
      ecd := ec[k];
      // 奇数ｺｰﾄﾞと偶数ｺｰﾄﾞを組合わせる
      for j := 1 to 9 do
        begin
          k := j mod 2;
          if k = 1 then
            ocd[j + 1] := ecd[j];
        end;
      Module := Module + ocd;
    end;
  Module := Module + se[1];

  result := Module;
end;

function Make_ITF(BarCode:String;CD:Boolean):String;
begin
  result := Make_TF(BarCode,0,CD);
end;

function Make_Customer(BarCode:String):String;
var
  ch,
  ch2:Byte;
  i,j,k:Integer;
  bc:array[0..10] of String[6];
  sc:array[0.. 7] of String[6];
  se:array[0.. 1] of String[6];
  Module:String;
begin
  // ０２３６７
  // □□□■■　　
  // □■■■■
  // □□■□■　

  bc[ 0] := '702020'; // 0
  bc[ 1] := '707020'; // 1
  bc[ 2] := '703060'; // 2
  bc[ 3] := '307060'; // 3
  bc[ 4] := '706030'; // 4
  bc[ 5] := '702070'; // 5
  bc[ 6] := '306070'; // 6
  bc[ 7] := '607030'; // 7
  bc[ 8] := '603070'; // 8
  bc[ 9] := '207070'; // 9
  bc[10] := '207020'; // -

  sc[0]  := '306020';
  sc[1]  := '302060';
  sc[2]  := '603020';
  sc[3]  := '203060';
  sc[4]  := '602030';
  sc[5]  := '206030';
  sc[6]  := '202070';
  sc[7]  := '707070';

  se[0]  := '007030'; // Start
  se[1]  := '307000'; // End

  // Start
  Module := se[0];
  j := 0;
  k := 0;
  for i:=1 to 20 do
    begin
      ch := Ord(Barcode[i]);
      case ch of
        // -,0..9
        45,
        48..57:
          begin
            if ch  = 45 then
              ch2 := 10
            else
              ch2 := ch-48;
            Module := Module + bc[ch2];
            Inc(j,ch2);
            Inc(k);
          end;
        // ' ',A..Z
        32,
        65..90:
          begin
            if (ch = 32) then
              begin
                Module := Module + sc[3];
                Inc(j,14);
                Inc(k);
              end
            else
              begin
                if k < 19 then
                  begin
                    ch2 := ((ch - 65) div 10);
                    Module := Module + sc[ch2];
                    Inc(j,ch2 + 11);
                    Inc(k);
                    ch2 := ((ch - 65) mod 10);
                    Module := Module + bc[ch2];
                    Inc(j,ch2);
                    Inc(k);
                  end
                else
                  begin
                    if (k <= 19) then
                      begin
                        Module := Module + sc[3];
                        Inc(j,14);
                        Inc(k);
                      end;
                  end;
              end;
          end;
        else
      end;
      if (k > 19) then
        break;
    end;

  // チェックディジット
  if (j mod 19) = 0 then
    j := 0
  else
    j := (19 - (j mod 19));
  case j of
    0..10:
      Module := Module + bc[j];
    11..18:
      Module := Module + sc[j-11];
  end;
  // End
  Module := Module + se[1];

  result := Module;
end;

function Make_Code128(BarCode:String;StartCode:Char):String;
var
  sc:array [$00..$66,0..3] of String;
  se:array [0..3] of String;
  EndCmd:Boolean;
  Command,
  Module:String;
  i,
  CD,
  Code,
  ShiftCode,
  Index,
  Count:Integer;
  function SearchCode(CD:Byte;Cmd:String):Integer;
  var
    i:Integer;
  begin
    result := -1;
    for i:=$00 to $66 do
      begin
        if sc[i][CD] = Cmd then
          begin
            result := i;
            Break;
          end;
      end;
  end;
begin
  sc[$00][0] := ' ';       sc[$00][1] := ' ';      sc[$00][2] := '00';    sc[$00][3] := '303232';
  sc[$01][0] := '!';       sc[$01][1] := '!';      sc[$01][2] := '01';    sc[$01][3] := '323032';
  sc[$02][0] := '"';       sc[$02][1] := '"';      sc[$02][2] := '02';    sc[$02][3] := '323230';
  sc[$03][0] := '#';       sc[$03][1] := '#';      sc[$03][2] := '03';    sc[$03][3] := '121234';
  sc[$04][0] := '$';       sc[$04][1] := '$';      sc[$04][2] := '04';    sc[$04][3] := '121432';
  sc[$05][0] := '%';       sc[$05][1] := '%';      sc[$05][2] := '05';    sc[$05][3] := '141232';
  sc[$06][0] := '&';       sc[$06][1] := '&';      sc[$06][2] := '06';    sc[$06][3] := '123214';
  sc[$07][0] := '''';      sc[$07][1] := '''';     sc[$07][2] := '07';    sc[$07][3] := '123412';
  sc[$08][0] := '(';       sc[$08][1] := '(';      sc[$08][2] := '08';    sc[$08][3] := '143212';
  sc[$09][0] := ')';       sc[$09][1] := ')';      sc[$09][2] := '09';    sc[$09][3] := '321214';
  sc[$0A][0] := '*';       sc[$0A][1] := '*';      sc[$0A][2] := '10';    sc[$0A][3] := '321412';
  sc[$0B][0] := '+';       sc[$0B][1] := '+';      sc[$0B][2] := '11';    sc[$0B][3] := '341212';
  sc[$0C][0] := ',';       sc[$0C][1] := ',';      sc[$0C][2] := '12';    sc[$0C][3] := '103252';
  sc[$0D][0] := '-';       sc[$0D][1] := '-';      sc[$0D][2] := '13';    sc[$0D][3] := '123052';
  sc[$0E][0] := '.';       sc[$0E][1] := '.';      sc[$0E][2] := '14';    sc[$0E][3] := '123250';
  sc[$0F][0] := '/';       sc[$0F][1] := '/';      sc[$0F][2] := '15';    sc[$0F][3] := '105232';
  sc[$10][0] := '0';       sc[$10][1] := '0';      sc[$10][2] := '16';    sc[$10][3] := '125032';
  sc[$11][0] := '1';       sc[$11][1] := '1';      sc[$11][2] := '17';    sc[$11][3] := '125230';
  sc[$12][0] := '2';       sc[$12][1] := '2';      sc[$12][2] := '18';    sc[$12][3] := '325210';
  sc[$13][0] := '3';       sc[$13][1] := '3';      sc[$13][2] := '19';    sc[$13][3] := '321052';
  sc[$14][0] := '4';       sc[$14][1] := '4';      sc[$14][2] := '20';    sc[$14][3] := '321250';
  sc[$15][0] := '5';       sc[$15][1] := '5';      sc[$15][2] := '21';    sc[$15][3] := '305212';
  sc[$16][0] := '6';       sc[$16][1] := '6';      sc[$16][2] := '22';    sc[$16][3] := '325012';
  sc[$17][0] := '7';       sc[$17][1] := '7';      sc[$17][2] := '23';    sc[$17][3] := '503050';
  sc[$18][0] := '8';       sc[$18][1] := '8';      sc[$18][2] := '24';    sc[$18][3] := '501232';
  sc[$19][0] := '9';       sc[$19][1] := '9';      sc[$19][2] := '25';    sc[$19][3] := '521032';
  sc[$1A][0] := ':';       sc[$1A][1] := ':';      sc[$1A][2] := '26';    sc[$1A][3] := '521230';
  sc[$1B][0] := ';';       sc[$1B][1] := ';';      sc[$1B][2] := '27';    sc[$1B][3] := '503212';
  sc[$1C][0] := '<';       sc[$1C][1] := '<';      sc[$1C][2] := '28';    sc[$1C][3] := '523012';
  sc[$1D][0] := '=';       sc[$1D][1] := '=';      sc[$1D][2] := '29';    sc[$1D][3] := '523210';
  sc[$1E][0] := '>';       sc[$1E][1] := '>';      sc[$1E][2] := '30';    sc[$1E][3] := '303034';
  sc[$1F][0] := '?';       sc[$1F][1] := '?';      sc[$1F][2] := '31';    sc[$1F][3] := '303430';
  sc[$20][0] := '@';       sc[$20][1] := '@';      sc[$20][2] := '32';    sc[$20][3] := '343030';
  sc[$21][0] := 'A';       sc[$21][1] := 'A';      sc[$21][2] := '33';    sc[$21][3] := '101434';
  sc[$22][0] := 'B';       sc[$22][1] := 'B';      sc[$22][2] := '34';    sc[$22][3] := '141034';
  sc[$23][0] := 'C';       sc[$23][1] := 'C';      sc[$23][2] := '35';    sc[$23][3] := '141430';
  sc[$24][0] := 'D';       sc[$24][1] := 'D';      sc[$24][2] := '36';    sc[$24][3] := '103414';
  sc[$25][0] := 'E';       sc[$25][1] := 'E';      sc[$25][2] := '37';    sc[$25][3] := '143014';
  sc[$26][0] := 'F';       sc[$26][1] := 'F';      sc[$26][2] := '38';    sc[$26][3] := '143410';
  sc[$27][0] := 'G';       sc[$27][1] := 'G';      sc[$27][2] := '39';    sc[$27][3] := '301414';
  sc[$28][0] := 'H';       sc[$28][1] := 'H';      sc[$28][2] := '40';    sc[$28][3] := '341014';
  sc[$29][0] := 'I';       sc[$29][1] := 'I';      sc[$29][2] := '41';    sc[$29][3] := '341410';
  sc[$2A][0] := 'J';       sc[$2A][1] := 'J';      sc[$2A][2] := '42';    sc[$2A][3] := '103054';
  sc[$2B][0] := 'K';       sc[$2B][1] := 'K';      sc[$2B][2] := '43';    sc[$2B][3] := '103450';
  sc[$2C][0] := 'L';       sc[$2C][1] := 'L';      sc[$2C][2] := '44';    sc[$2C][3] := '143050';
  sc[$2D][0] := 'M';       sc[$2D][1] := 'M';      sc[$2D][2] := '45';    sc[$2D][3] := '105034';
  sc[$2E][0] := 'N';       sc[$2E][1] := 'N';      sc[$2E][2] := '46';    sc[$2E][3] := '105430';
  sc[$2F][0] := 'O';       sc[$2F][1] := 'O';      sc[$2F][2] := '47';    sc[$2F][3] := '145030';
  sc[$30][0] := 'P';       sc[$30][1] := 'P';      sc[$30][2] := '48';    sc[$30][3] := '505030';
  sc[$31][0] := 'Q';       sc[$31][1] := 'Q';      sc[$31][2] := '49';    sc[$31][3] := '301450';
  sc[$32][0] := 'R';       sc[$32][1] := 'R';      sc[$32][2] := '50';    sc[$32][3] := '341050';
  sc[$33][0] := 'S';       sc[$33][1] := 'S';      sc[$33][2] := '51';    sc[$33][3] := '305014';
  sc[$34][0] := 'T';       sc[$34][1] := 'T';      sc[$34][2] := '52';    sc[$34][3] := '305410';
  sc[$35][0] := 'U';       sc[$35][1] := 'U';      sc[$35][2] := '53';    sc[$35][3] := '305050';
  sc[$36][0] := 'V';       sc[$36][1] := 'V';      sc[$36][2] := '54';    sc[$36][3] := '501034';
  sc[$37][0] := 'W';       sc[$37][1] := 'W';      sc[$37][2] := '55';    sc[$37][3] := '501430';
  sc[$38][0] := 'X';       sc[$38][1] := 'X';      sc[$38][2] := '56';    sc[$38][3] := '541030';
  sc[$39][0] := 'Y';       sc[$39][1] := 'Y';      sc[$39][2] := '57';    sc[$39][3] := '503014';
  sc[$3A][0] := 'Z';       sc[$3A][1] := 'Z';      sc[$3A][2] := '58';    sc[$3A][3] := '503410';
  sc[$3B][0] := '[';       sc[$3B][1] := '[';      sc[$3B][2] := '59';    sc[$3B][3] := '543010';
  sc[$3C][0] := '\';       sc[$3C][1] := '\';      sc[$3C][2] := '60';    sc[$3C][3] := '507010';
  sc[$3D][0] := ']';       sc[$3D][1] := ']';      sc[$3D][2] := '61';    sc[$3D][3] := '321610';
  sc[$3E][0] := '^';       sc[$3E][1] := '^';      sc[$3E][2] := '62';    sc[$3E][3] := '741010';
  sc[$3F][0] := '_';       sc[$3F][1] := '_';      sc[$3F][2] := '63';    sc[$3F][3] := '101236';
  sc[$40][0] := 'NUL';     sc[$40][1] := '`';      sc[$40][2] := '64';    sc[$40][3] := '101632';
  sc[$41][0] := 'SOH';     sc[$41][1] := 'a';      sc[$41][2] := '65';    sc[$41][3] := '121036';
  sc[$42][0] := 'STX';     sc[$42][1] := 'b';      sc[$42][2] := '66';    sc[$42][3] := '121630';
  sc[$43][0] := 'ETX';     sc[$43][1] := 'c';      sc[$43][2] := '67';    sc[$43][3] := '161032';
  sc[$44][0] := 'EOT';     sc[$44][1] := 'd';      sc[$44][2] := '68';    sc[$44][3] := '161230';
  sc[$45][0] := 'ENO';     sc[$45][1] := 'e';      sc[$45][2] := '69';    sc[$45][3] := '103216';
  sc[$46][0] := 'ACK';     sc[$46][1] := 'f';      sc[$46][2] := '70';    sc[$46][3] := '103612';
  sc[$47][0] := 'BEL';     sc[$47][1] := 'g';      sc[$47][2] := '71';    sc[$47][3] := '123016';
  sc[$48][0] := 'BS';      sc[$48][1] := 'h';      sc[$48][2] := '72';    sc[$48][3] := '123610';
  sc[$49][0] := 'HT';      sc[$49][1] := 'i';      sc[$49][2] := '73';    sc[$49][3] := '163012';
  sc[$4A][0] := 'LF';      sc[$4A][1] := 'j';      sc[$4A][2] := '74';    sc[$4A][3] := '163210';
  sc[$4B][0] := 'VT';      sc[$4B][1] := 'k';      sc[$4B][2] := '75';    sc[$4B][3] := '361210';
  sc[$4C][0] := 'FF';      sc[$4C][1] := 'l';      sc[$4C][2] := '76';    sc[$4C][3] := '321016';
  sc[$4D][0] := 'CR';      sc[$4D][1] := 'm';      sc[$4D][2] := '77';    sc[$4D][3] := '705010';
  sc[$4E][0] := 'SO';      sc[$4E][1] := 'n';      sc[$4E][2] := '78';    sc[$4E][3] := '361012';
  sc[$4F][0] := 'SI';      sc[$4F][1] := 'o';      sc[$4F][2] := '79';    sc[$4F][3] := '147010';
  sc[$50][0] := 'DLE';     sc[$50][1] := 'p';      sc[$50][2] := '80';    sc[$50][3] := '101272';
  sc[$51][0] := 'DC1';     sc[$51][1] := 'q';      sc[$51][2] := '81';    sc[$51][3] := '121072';
  sc[$52][0] := 'DC2';     sc[$52][1] := 'r';      sc[$52][2] := '82';    sc[$52][3] := '121270';
  sc[$53][0] := 'DC3';     sc[$53][1] := 's';      sc[$53][2] := '83';    sc[$53][3] := '107212';
  sc[$54][0] := 'DC4';     sc[$54][1] := 't';      sc[$54][2] := '84';    sc[$54][3] := '127012';
  sc[$55][0] := 'NAK';     sc[$55][1] := 'u';      sc[$55][2] := '85';    sc[$55][3] := '127210';
  sc[$56][0] := 'SYN';     sc[$56][1] := 'v';      sc[$56][2] := '86';    sc[$56][3] := '701212';
  sc[$57][0] := 'ETB';     sc[$57][1] := 'w';      sc[$57][2] := '87';    sc[$57][3] := '721012';
  sc[$58][0] := 'CAN';     sc[$58][1] := 'x';      sc[$58][2] := '88';    sc[$58][3] := '721210';
  sc[$59][0] := 'EM';      sc[$59][1] := 'y';      sc[$59][2] := '89';    sc[$59][3] := '303070';
  sc[$5A][0] := 'SUB';     sc[$5A][1] := 'z';      sc[$5A][2] := '90';    sc[$5A][3] := '307030';
  sc[$5B][0] := 'ESC';     sc[$5B][1] := '{';      sc[$5B][2] := '91';    sc[$5B][3] := '703030';
  sc[$5C][0] := 'FS';      sc[$5C][1] := '|';      sc[$5C][2] := '92';    sc[$5C][3] := '101074';
  sc[$5D][0] := 'GS';      sc[$5D][1] := '}';      sc[$5D][2] := '93';    sc[$5D][3] := '101470';
  sc[$5E][0] := 'RS';      sc[$5E][1] := '~';      sc[$5E][2] := '94';    sc[$5E][3] := '141070';
  sc[$5F][0] := 'US';      sc[$5F][1] := 'DEL';    sc[$5F][2] := '95';    sc[$5F][3] := '107014';
  sc[$60][0] := 'FNC3';    sc[$60][1] := 'FNC3';   sc[$60][2] := '96';    sc[$60][3] := '107410';
  sc[$61][0] := 'FNC2';    sc[$61][1] := 'FNC2';   sc[$61][2] := '97';    sc[$61][3] := '701014';
  sc[$62][0] := 'SHIFT';   sc[$62][1] := 'SHIFT';  sc[$62][2] := '98';    sc[$62][3] := '701410';
  sc[$63][0] := 'CODEC';   sc[$63][1] := 'CODEC';  sc[$63][2] := '99';    sc[$63][3] := '105070';
  sc[$64][0] := 'CODEB';   sc[$64][1] := 'FNC4';   sc[$64][2] := 'CODEB'; sc[$64][3] := '107050';
  sc[$65][0] := 'FNC4';    sc[$65][1] := 'CODEA';  sc[$65][2] := 'CODEA'; sc[$65][3] := '501070';
  sc[$66][0] := 'FNC1';    sc[$66][1] := 'FNC1';   sc[$66][2] := 'FNC1';  sc[$66][3] := '701050';

  se[0] := '301612';  // StartA
  se[1] := '301216';  // StartB
  se[2] := '301252';  // StartC
  se[3] := '3450103'; // Stop

  ShiftCode := -1;
  Code      := Ord(StartCode) - Ord('A');
  Count     := 0;

  if (Code < 0) or (Code > 2) then
    begin
      result := '';
      Exit;
    end;

  // スタートコード
  Module    := se[Code];
  CD        := $67 + Code;

  // コード
  i := 1;
  while (i<=Length(BarCode)) do
    begin
      if Barcode[i] = '<' then
        begin
          Inc(i);
          if Barcode[i] ='<' then
            Command := Barcode[i]
          else
            begin
              Command := '';
              EndCmd := False;
              repeat
                Command := Command + Barcode[i];
                Inc(i);
                if (Barcode[i] = '>') or (Length(BarCode) < i) then
                  EndCmd := True;
              until(EndCmd);
              Command := UpperCase(Command);
            end
        end
      else if Barcode[i] = '>' then
        begin
          Inc(i);
          Command := Barcode[i]
        end
      else
        Command := Barcode[i];

      Index := SearchCode(Code,Command);
      if Index < 0 then
        begin
          result := '';
          Exit;
        end
      else
        begin
          Inc(Count);
          CD := CD + (Index * Count);
          Module := Module + sc[Index][3];
          Inc(i);
          if Command = 'SHIFT' then
            begin
              ShiftCode := Code;
              // A->B,B->C,C->A
              Code := (Code + 1) mod 3;
            end
          else if (Command = 'CODEA') then
            Code := 0
          else if (Command = 'CODEB') then
            Code := 1
          else if (Command = 'CODEC') then
            Code := 2
          else
            begin
              if ShiftCode >= 0 then
                begin
                  Code := ShiftCode;
                  ShiftCode := -1;
                end;
            end;
        end;
    end;
  // チェックディジット
  CD := (CD mod 103);
  Module := Module + sc[CD][3];
  // ストップコード
  Module := Module + se[3];

  result := Module;  
end;
end.

















