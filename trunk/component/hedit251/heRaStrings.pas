(*********************************************************************

  heRaStrings.pas

  start  2001/04/08
  update 2001/09/22

  Copyright (c) 2001 本田勝彦 <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  TEditor 内部で利用される文字列リストクラスの基底クラス
  TRowAttribute 型データの他、１行文字列をパースするために必要な
  データと、ビットマップを表示するためのデータを保持する。
**********************************************************************)

unit heRaStrings;

{$I heverdef.inc}

interface

uses
  Classes, heStringList;

const
  BracketItemLimit    = 14;
  InvalidBracketIndex = -2;
  NormalBracketIndex  = -1;
  NormalElementIndex  = 0;

type
  TPointerStringList = class(TStringList)
  private
    FDataList: TList;
    FItemList: TList;
    FItemList2: TList;
    function GetData(Index: Integer): Pointer;
    procedure PutData(Index: Integer; Data: Pointer);
    function GetItem(Index: Integer): Pointer;
    procedure PutItem(Index: Integer; Item: Pointer);
    function GetItem2(Index: Integer): Pointer;
    procedure PutItem2(Index: Integer; Item: Pointer);
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const S: String): Integer; override;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Insert(Index: Integer; const S: String); override;
    property Datas[Index: Integer]: Pointer read GetData write PutData;
    property Items[Index: Integer]: Pointer read GetItem write PutItem;
    property Items2[Index: Integer]: Pointer read GetItem2 write PutItem2;
  end;

  TRowAttribute = (raCrlf, raWrapped, raEof, raInvalid);

  TRowAttributeData = record
    RowAttribute: TRowAttribute;
    PrevRowAttribute: TRowAttribute;
    BracketIndex: Integer;
    ElementIndex: Integer;
    WrappedByte: Integer;
    Remain: Integer;
    StartToken: Char;
    PrevToken: Char;
    DataStr: String;
  end;

  TRowMark = (rm0,  rm1,  rm2,  rm3,  rm4,  rm5,  rm6,  rm7,
              rm8,  rm9, rm10, rm11, rm12, rm13, rm14, rm15);
  TRowMarks = set of TRowMark;

  TRowAttributeStringList = class(TheStringList)
  private
    function GetRows(Index: Integer): TRowAttribute;
    procedure SetRows(Index: Integer; Value: TRowAttribute);
    function GetPrevRows(Index: Integer): TRowAttribute;
    procedure SetPrevRows(Index: Integer; Value: TRowAttribute);
    function GetBrackets(Index: Integer): Integer;
    procedure SetBrackets(Index: Integer; Value: Integer);
    function GetElements(Index: Integer): Integer;
    procedure SetElements(Index: Integer; Value: Integer);
    function GetWrappedBytes(Index: Integer): Integer;
    procedure SetWrappedBytes(Index: Integer; Value: Integer);
    function GetTokens(Index: Integer): Char;
    procedure SetTokens(Index: Integer; Value: Char);
    function GetPrevTokens(Index: Integer): Char;
    procedure SetPrevTokens(Index: Integer; Value: Char);
    function GetRowMarks(Index: Integer): TRowMarks;
    procedure SetRowMarks(Index: Integer; Value: TRowMarks);
    function GetRemains(Index: Integer): Integer;
    procedure SetRemains(Index: Integer; Value: Integer);
  public
    property Rows[Index: Integer]: TRowAttribute read GetRows write SetRows;
    property PrevRows[Index: Integer]: TRowAttribute read GetPrevRows write SetPrevRows;
    property Brackets[Index: Integer]: Integer read GetBrackets write SetBrackets;
    property Elements[Index: Integer]: Integer read GetElements write SetElements;
    property WrappedBytes[Index: Integer]: Integer read GetWrappedBytes write SetWrappedBytes;
    property Tokens[Index: Integer]: Char read GetTokens write SetTokens;
    property PrevTokens[Index: Integer]: Char read GetPrevTokens write SetPrevTokens;
    property Remains[Index: Integer]: Integer read GetRemains write SetRemains;
    property RowMarks[Index: Integer]: TRowmarks read GetRowMarks write SetRowMarks;
  end;


implementation


{ TPointerStringList }

(*
  ver 2.25 の TEditor から heStringList.pas に記述された
  TheStringList が  TRowAttributeStringList の基底クラス
  として利用されています。TPointerStringList は利用されて
  いませんが、削除せずに残してあります。
*)

constructor TPointerStringList.Create;
begin
  FDataList := TList.Create;
  FItemList := TList.Create;
  FItemList2 := TList.Create;
end;

destructor TPointerStringList.Destroy;
begin
  FDataList.Free;
  FItemList.Free;
  FItemList2.Free;
  inherited Destroy;
end;

function TPointerStringList.GetData(Index: Integer): Pointer;
begin
  Result := FDataList[Index];
end;

procedure TPointerStringList.PutData(Index: Integer; Data: Pointer);
begin
  FDataList[Index] := Data;
end;

function TPointerStringList.GetItem(Index: Integer): Pointer;
begin
  Result := FItemList[Index];
end;

procedure TPointerStringList.PutItem(Index: Integer; Item: Pointer);
begin
  FItemList[Index] := Item;
end;

function TPointerStringList.GetItem2(Index: Integer): Pointer;
begin
  Result := FItemList2[Index];
end;

procedure TPointerStringList.PutItem2(Index: Integer; Item: Pointer);
begin
  FItemList2[Index] := Item;
end;

function TPointerStringList.Add(const S: String): Integer;
begin
  FDataList.Add(nil);
  FItemList.Add(nil);
  FItemList2.Add(nil);
  Result := inherited Add(S);
end;

procedure TPointerStringList.Clear;
begin
  FDataList.Clear;
  FItemList.Clear;
  FItemList2.Clear;
  inherited Clear;
end;

procedure TPointerStringList.Delete(Index: Integer);
begin
  FDataList.Delete(Index);
  FItemList.Delete(Index);
  FItemList2.Delete(Index);
  inherited Delete(Index);
end;

procedure TPointerStringList.Insert(Index: Integer; const S: String);
begin
  FDataList.Insert(Index, nil);
  FItemList.Insert(Index, nil);
  FItemList2.Insert(Index, nil);
  inherited Insert(Index, S);
end;


{ TRowAttributeStringList }

(*
  Items に格納されるデータ
    29   25   21   17   13    9    5    1
  0000 0000 0000 0000 0000 0000 0000 0000
                         get                          set
  Rows         : 1..2    Items and $3                 Items and $FFFFFFFC or Value
  PrevRows     : 3..4    Items and $C shr 2           Items and $FFFFFFF3 or Value shl 2
  Brackets     : 5..8    Items and $F0 shr 4          Items and $FFFFFF0F or Value shl 4
  Elements     : 9..16   Items and $FF00 shr 8        Items and $FFFF00FF or Value shl 8
  WrappedBytes : 17..24  Items and $FF0000 shr 16     Items and $FF00FFFF or Value shl 16
  Remains      : 25..32  Items and $FF000000 shr 24   Items and $00FFFFFF or Value shl 24

  Items2 に格納されるデータ
    29   25   21   17   13    9    5    1
  0000 0000 0000 0000 0000 0000 0000 0000
                         get                          set
  Tokens       : 1..8    Items2 and $FF               Items2 and $FFFFFF00 or Value
  PrevTokens   : 9..16   Items2 and $FF00 shr 8       Items2 and $FFFF00FF or Value shl 8
  RowMarks     : 17..32  Items2 and $FFFF0000 shr 16  Items2 and $FFFF0000 or Value shl 16


  TRowMarks と Word 値

  0000 0000 0000 0000                  0000 0000 0000 0000
                    1      1     $1                      1      1     $1
                   10      2     $2                     11      3     $3
                  100      4     $4                    111      7     $7
                 1000      8     $8                   1111     15     $F
               1 0000     16    $10                 1 1111     31    $1F
              10 0000     32    $20                11 1111     63    $3F
             100 0000     64    $40               111 1111    127    $7F
            1000 0000    128    $80              1111 1111    255    $FF
          1 0000 0000    256   $100            1 1111 1111    511   $1FF
         10 0000 0000    512   $200           11 1111 1111   1023   $3FF
        100 0000 0000   1024   $400          111 1111 1111   2047   $7FF
       1000 0000 0000   2048   $800         1111 1111 1111   4095   $FFF
     1 0000 0000 0000   4096  $1000       1 1111 1111 1111   8191  $1FFF
    10 0000 0000 0000   8192  $2000      11 1111 1111 1111  16383  $3FFF
   100 0000 0000 0000  16384  $4000     111 1111 1111 1111  32767  $7FFF
  1000 0000 0000 0000  32768  $8000    1111 1111 1111 1111  65535  $FFFF
*)

// Rows プロパティのアクセスメソッド
function TRowAttributeStringList.GetRows(Index: Integer): TRowAttribute;
begin
  Result := TRowAttribute(Integer(Items[Index]) and $3);
end;

procedure TRowAttributeStringList.SetRows(Index: Integer; Value: TRowAttribute);
begin
  Items[Index] := Pointer((Integer(Items[Index]) and $FFFFFFFC) or Byte(Ord(Value)));
end;

// PrevRows プロパティのアクセスメソッド
function TRowAttributeStringList.GetPrevRows(Index: Integer): TRowAttribute;
begin
  Result := TRowAttribute((Integer(Items[Index]) and $C) shr 2);
end;

procedure TRowAttributeStringList.SetPrevRows(Index: Integer; Value: TRowAttribute);
begin
  Items[Index] := Pointer((Integer(Items[Index]) and $FFFFFFF3) or (Byte(Ord(Value)) shl 2));
end;

// Brackets プロパティのアクセスメソッド
(*
  実際の値    返値    意味
         0      -2    不定     InvalidBracketIndex
         1      -1    ノーマル NormalBracketIndex
         2       0    BracketCollection へのインデックス

  Items[Index] の 5..8 の４ビットに格納されるので、2..15 までの１４個が
  BracketCollection.Count の上限となる
*)
function TRowAttributeStringList.GetBrackets(Index: Integer): Integer;
begin
  Result := ((Integer(Items[Index]) and $F0) shr 4) - 2;
end;

procedure TRowAttributeStringList.SetBrackets(Index: Integer; Value: Integer);
begin
  Items[Index] := Pointer((Integer(Items[Index]) and $FFFFFF0F) or (Byte((Value + 2)) shl 4));
end;

// Elements プロパティのアクセスメソッド
(*
  NormalElementIndex = 0; とする。
  ElementIndex を利用する際は最初のインデックスを１とすること。
  Items[Index] の 9..16 の８ビットに格納されるので、1..255 までの２５５個が
  ElementIndex の上限となる
*)
function TRowAttributeStringList.GetElements(Index: Integer): Integer;
begin
  Result := (Integer(Items[Index]) and $FF00) shr 8;
end;

procedure TRowAttributeStringList.SetElements(Index: Integer; Value: Integer);
begin
  Items[Index] := Pointer((Integer(Items[Index]) and $FFFF00FF) or (Byte(Value) shl 8));
end;

// WrappedBytes プロパティのアクセスメソッド
function TRowAttributeStringList.GetWrappedBytes(Index: Integer): Integer;
begin
  Result := (Integer(Items[Index]) and $FF0000) shr 16;
end;

procedure TRowAttributeStringList.SetWrappedBytes(Index: Integer; Value: Integer);
begin
  Items[Index] := Pointer((Integer(Items[Index]) and $FF00FFFF) or (Byte(Value) shl 16));
end;

// Remains プロパティのアクセスメソッド
function TRowAttributeStringList.GetRemains(Index: Integer): Integer;
begin
  Result := (Integer(Items[Index]) and $FF000000) shr 24;
end;

procedure TRowAttributeStringList.SetRemains(Index: Integer; Value: Integer);
begin
  Items[Index] := Pointer((Integer(Items[Index]) and $FFFFFF) or (Value shl 24));
end;

// Tokens プロパティのアクセスメソッド
function TRowAttributeStringList.GetTokens(Index: Integer): Char;
begin
  Result := Char((Integer(Items2[Index]) and $FF));
end;

procedure TRowAttributeStringList.SetTokens(Index: Integer; Value: Char);
begin
  Items2[Index] := Pointer((Integer(Items2[Index]) and $FFFFFF00) or Ord(Value));
end;

// PrevTokens プロパティのアクセスメソッド
function TRowAttributeStringList.GetPrevTokens(Index: Integer): Char;
begin
  Result := Char((Integer(Items2[Index]) and $FF00) shr 8);
end;

procedure TRowAttributeStringList.SetPrevTokens(Index: Integer; Value: Char);
begin
  Items2[Index] := Pointer((Integer(Items2[Index]) and $FFFF00FF) or (Ord(Value) shl 8));
end;

// RowMarks プロパティのアクセスメソッド
function TRowAttributeStringList.GetRowMarks(Index: Integer): TRowMarks;
begin
  Result := TRowMarks(Word(Integer(Items2[Index]) shr 16));
end;

procedure TRowAttributeStringList.SetRowMarks(Index: Integer; Value: TRowMarks);
begin
  Items2[Index] := Pointer((Integer(Items2[Index]) and $FFFF) or (Word(Value) shl 16));
end;

end.

