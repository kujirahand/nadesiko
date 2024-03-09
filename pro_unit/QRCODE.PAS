unit QRCode;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Clipbrd;

const
  { 符号化モード }
  QR_EM_NUMERIC = 0; // 数字
  QR_EM_ALNUM   = 1; // 英数字: 0-9 A-Z SP $%*+-./:
  QR_EM_8BIT    = 2; // 8ビットバイト
  QR_EM_KANJI   = 3; // 漢字
  QR_EM_MAX     = 4; // モード総数

  { 誤り訂正レベル }
  QR_ECL_L   = 0; // レベルL
  QR_ECL_M   = 1; // レベルM
  QR_ECL_Q   = 2; // レベルQ
  QR_ECL_H   = 3; // レベルH
  QR_ECL_MAX = 4; // レベル総数

  { モジュール値のマスク }
  QR_MM_DATA  = $01; // 符号化データの黒モジュール
  QR_MM_BLACK = $02; // 印字される黒モジュール
  QR_MM_FUNC  = $04; // 機能パターン領域(形式/型番情報を含む)

  { 機能パターンの定数 }
  QR_DIM_SEP    = 4; // 分離パターンの幅
  QR_DIM_FINDER = 7; // 位置検出パターンの1辺の長さ
  QR_DIM_ALIGN  = 5; // 位置合わせパターンの1辺の長さ
  QR_DIM_TIMING = 6; // タイミングパターンのオフセット位置

  { サイズ定数 }
  QR_SRC_MAX = 7089; // 入力データの最大長
  QR_DIM_MAX = 177;  // 1辺のモジュール数の最大値
  QR_VER_MAX = 40;   // 型番の最大値
  QR_DWD_MAX = 2956; // データコード語の最大長(型番40/レベルL)
  QR_ECW_MAX = 2430; // 誤り訂正コード語の最大長(型番40/レベルH)
  QR_CWD_MAX = 3706; // コード語の最大長(型番40)
  QR_RSD_MAX = 123;  // RSブロックデータコード語の最大長
  QR_RSW_MAX = 68;   // RSブロック誤り訂正コード語の最大長
  QR_RSB_MAX = 2;    // RSブロック種別の最大数
  QR_MPT_MAX = 8;    // マスクパターン種別総数
  QR_APL_MAX = 7;    // 位置合わせパターン座標の最大数
  QR_FIN_MAX = 15;   // 形式情報のビット数
  QR_VIN_MAX = 18;   // 型番情報のビット数

  { その他の定数 }
  NAV      = 0;   // 不使用(not available)
  PADWORD1 = $EC; // 埋め草コード語1: 11101100
  PADWORD2 = $11; // 埋め草コード語2: 00010001

type
  { RSブロックごとの情報 }
  QR_RSBLOCK = record
    rsbnum: Integer;     // RSブロック数
    totalwords: Integer; // RSブロック総コード語数
    datawords: Integer;  // RSブロックデータコード語数
    ecnum: Integer;      // RSブロック誤り訂正数(不使用)
  end;

  { 誤り訂正レベルごとの情報 }
  QR_ECLEVEL = record
    datawords: Integer;                         // データコード語数(全RSブロック)
    capacity: array[0..QR_EM_MAX - 1] of Integer; // 符号化モードごとのデータ容量
    nrsb: Integer;                                // RSブロックの種類(1または2)
    rsb: array[0..QR_RSB_MAX - 1] of QR_RSBLOCK;  // RSブロックごとの情報
  end;

  { 型番ごとの情報 }
  QR_VERTABLE = record
    version: Integer;                            // 型番
    dimension: Integer;                          // 1辺のモジュール数
    totalwords: Integer;                         // 総コード語数
    remainedbits: Integer;                       // 剰余ビット数
    nlen: array[0..QR_EM_MAX - 1] of Integer;    // 文字数指示子のビット数
    ecl: array[0..QR_ECL_MAX - 1] of QR_ECLEVEL; // 誤り訂正レベルごとの情報
    aplnum: Integer;                             // 位置合わせパターン中心座標数
    aploc: array[0..QR_APL_MAX - 1] of Integer;  // 位置合わせパターン中心座標
  end;

  PByte = ^Byte;

const
  { αのべき表現→多項式係数の整数表現 }
  exp2fac: array[0..255] of Byte = (
      1,  2,  4,  8, 16, 32, 64,128, 29, 58,116,232,205,135, 19, 38,
     76,152, 45, 90,180,117,234,201,143,  3,  6, 12, 24, 48, 96,192,
    157, 39, 78,156, 37, 74,148, 53,106,212,181,119,238,193,159, 35,
     70,140,  5, 10, 20, 40, 80,160, 93,186,105,210,185,111,222,161,
     95,190, 97,194,153, 47, 94,188,101,202,137, 15, 30, 60,120,240,
    253,231,211,187,107,214,177,127,254,225,223,163, 91,182,113,226,
    217,175, 67,134, 17, 34, 68,136, 13, 26, 52,104,208,189,103,206,
    129, 31, 62,124,248,237,199,147, 59,118,236,197,151, 51,102,204,
    133, 23, 46, 92,184,109,218,169, 79,158, 33, 66,132, 21, 42, 84,
    168, 77,154, 41, 82,164, 85,170, 73,146, 57,114,228,213,183,115,
    230,209,191, 99,198,145, 63,126,252,229,215,179,123,246,241,255,
    227,219,171, 75,150, 49, 98,196,149, 55,110,220,165, 87,174, 65,
    130, 25, 50,100,200,141,  7, 14, 28, 56,112,224,221,167, 83,166,
     81,162, 89,178,121,242,249,239,195,155, 43, 86,172, 69,138,  9,
     18, 36, 72,144, 61,122,244,245,247,243,251,235,203,139, 11, 22,
     44, 88,176,125,250,233,207,131, 27, 54,108,216,173, 71,142,  1
  );

  { 多項式係数の整数表現→αのべき表現 }
  fac2exp: array[0..255] of Byte = (
    NAV,  0,  1, 25,  2, 50, 26,198,  3,223, 51,238, 27,104,199, 75,
      4,100,224, 14, 52,141,239,129, 28,193,105,248,200,  8, 76,113,
      5,138,101, 47,225, 36, 15, 33, 53,147,142,218,240, 18,130, 69,
     29,181,194,125,106, 39,249,185,201,154,  9,120, 77,228,114,166,
      6,191,139, 98,102,221, 48,253,226,152, 37,179, 16,145, 34,136,
     54,208,148,206,143,150,219,189,241,210, 19, 92,131, 56, 70, 64,
     30, 66,182,163,195, 72,126,110,107, 58, 40, 84,250,133,186, 61,
    202, 94,155,159, 10, 21,121, 43, 78,212,229,172,115,243,167, 87,
      7,112,192,247,140,128, 99, 13,103, 74,222,237, 49,197,254, 24,
    227,165,153,119, 38,184,180,124, 17, 68,146,217, 35, 32,137, 46,
     55, 63,209, 91,149,188,207,205,144,135,151,178,220,252,190, 97,
    242, 86,211,171, 20, 42, 93,158,132, 60, 57, 83, 71,109, 65,162,
     31, 45, 67,216,183,123,164,118,196, 23, 73,236,127, 12,111,246,
    108,161, 59, 82, 41,157, 85,170,251, 96,134,177,187,204, 62, 90,
    203, 89, 95,176,156,169,160, 81, 11,245, 22,235,122,117, 44,215,
     79,174,213,233,230,231,173,232,116,214,244,234,168, 80, 88,175
  );

  { 誤り訂正生成多項式の第2項以降の係数表(べき表現) }
  gftable: array[0..QR_RSW_MAX, 0..QR_RSW_MAX - 1] of Byte = (
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (87,229,146,149,238,102,21,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (251,67,46,61,118,70,64,94,32,45,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (74,152,176,100,86,100,106,104,130,218,206,140,78,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (8,183,61,91,202,37,51,58,58,237,140,124,5,99,105,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (120,104,107,109,102,161,76,3,91,191,147,169,182,194,225,120,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (43,139,206,78,43,239,123,206,214,147,24,99,150,39,243,163,136,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (215,234,158,94,184,97,118,170,79,187,152,148,252,179,5,98,96,153,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (17,60,79,50,61,163,26,187,202,180,221,225,83,239,156,164,212,212,188,190,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (210,171,247,242,93,230,14,109,221,53,200,74,8,172,98,80,219,134,160,105,165,231,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (229,121,135,48,211,117,251,126,159,180,169,152,192,226,228,218,111,0,117,232,87,96,227,21,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (173,125,158,2,103,182,118,17,145,201,111,28,165,53,161,21,245,142,13,102,48,227,153,145,218,70,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (168,223,200,104,224,234,108,180,110,190,195,147,205,27,232,201,21,43,245,87,42,195,212,119,242,37,9,123,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (41,173,145,152,216,31,179,182,50,48,110,86,239,96,222,125,42,173,226,193,224,130,156,37,251,216,238,40,192,180,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (10,6,106,190,249,167,4,67,209,138,138,32,242,123,89,27,120,185,80,156,38,69,171,60,28,222,80,52,254,185,220,241,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (111,77,146,94,26,21,108,19,105,94,113,193,86,140,163,125,58,158,229,239,218,103,56,70,114,61,183,129,167,13,98,62,129,51,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (200,183,98,16,172,31,246,234,60,152,115,0,167,152,113,248,238,107,18,63,218,37,87,210,105,177,120,74,121,196,117,251,113,233,30,120,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (159,34,38,228,230,59,243,95,49,218,176,164,20,65,45,111,39,81,49,118,113,222,193,250,242,168,217,41,164,247,177,30,238,18,120,153,60,193,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (59,116,79,161,252,98,128,205,128,161,247,57,163,56,235,106,53,26,187,174,226,104,170,7,175,35,181,114,88,41,47,163,125,134,72,20,232,53,35,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (250,103,221,230,25,18,137,231,0,3,58,242,221,191,110,84,230,8,188,106,96,147,15,131,139,34,101,223,39,101,213,199,237,254,201,123,171,162,194,117,50,96,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (190,7,61,121,71,246,69,55,168,188,89,243,191,25,72,123,9,145,14,247,1,238,44,78,143,62,224,126,118,114,68,163,52,194,217,147,204,169,37,130,113,102,73,181,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (112,94,88,112,253,224,202,115,187,99,89,5,54,113,129,44,58,16,135,216,169,211,36,1,4,96,60,241,73,104,234,8,249,245,119,174,52,25,157,224,43,202,223,19,82,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (228,25,196,130,211,146,60,24,251,90,39,102,240,61,178,63,46,123,115,18,221,111,135,160,182,205,107,206,95,150,120,184,91,21,247,156,140,238,191,11,94,227,84,50,163,39,34,108,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (232,125,157,161,164,9,118,46,209,99,203,193,35,3,209,111,195,242,203,225,46,13,32,160,126,209,130,160,242,215,242,75,77,42,189,32,113,65,124,69,228,114,235,175,124,170,215,232,133,205,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (116,50,86,186,50,220,251,89,192,46,86,127,124,19,184,233,151,215,22,14,59,145,37,242,203,134,254,89,190,94,59,65,124,113,100,233,235,121,22,76,86,97,39,242,200,220,101,33,239,254,116,51,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (183,26,201,87,210,221,113,21,46,65,45,50,238,184,249,225,102,58,209,218,109,165,26,95,184,192,52,245,35,254,238,175,172,79,123,25,122,43,120,108,215,80,128,201,235,8,153,59,101,31,198,76,31,156,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (106,120,107,157,164,216,112,116,2,91,248,163,36,201,202,229,6,144,254,155,135,208,170,209,12,139,127,142,182,249,177,174,190,28,10,85,239,184,101,124,152,206,96,23,163,61,27,196,247,151,154,202,207,20,61,10,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (82,116,26,247,66,27,62,107,252,182,200,185,235,55,251,242,210,144,154,237,176,141,192,248,152,249,206,85,253,142,65,165,125,23,24,30,122,240,214,6,129,218,29,145,127,134,206,245,117,29,41,63,159,142,233,125,148,123,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (107,140,26,12,9,141,243,197,226,197,219,45,211,101,219,120,28,181,127,6,100,247,2,205,198,57,115,219,101,109,160,82,37,38,238,49,160,209,121,86,11,124,30,181,84,25,194,87,65,102,190,220,70,27,209,16,89,7,33,240,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (65,202,113,98,71,223,248,118,214,94,0,122,37,23,2,228,58,121,7,105,135,78,243,118,70,76,223,89,72,50,70,111,194,17,212,126,181,35,221,117,235,11,229,149,147,123,213,40,115,6,200,100,26,246,182,218,127,215,36,186,110,106,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (45,51,175,9,7,158,159,49,68,119,92,123,177,204,187,254,200,78,141,149,119,26,127,53,160,93,199,212,29,24,145,156,208,150,218,209,4,216,91,47,184,146,47,140,195,195,125,242,238,63,99,108,140,230,242,31,204,11,178,243,217,156,213,231,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (5,118,222,180,136,136,162,51,46,117,13,215,81,17,139,247,197,171,95,173,65,137,178,68,111,95,101,41,72,214,169,197,95,7,44,154,77,111,236,40,121,143,63,87,80,253,240,126,217,77,34,232,106,50,168,82,76,146,67,106,171,25,132,93,45,105,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (247,159,223,33,224,93,77,70,90,160,32,254,43,150,84,101,190,205,133,52,60,202,165,220,203,151,93,84,15,84,253,173,160,89,227,52,199,97,95,231,52,177,41,125,137,241,166,225,118,2,54,32,82,215,175,198,43,238,235,27,101,184,127,3,5,8,163,238)
  );

  F0 = QR_MM_FUNC;
  F1 = (QR_MM_FUNC or QR_MM_BLACK);

  { 位置検出パターンのデータ }
  finderpattern: array[0..QR_DIM_FINDER - 1, 0..QR_DIM_FINDER - 1] of Byte = (
    (F1, F1, F1, F1, F1, F1, F1),
    (F1, F0, F0, F0, F0, F0, F1),
    (F1, F0, F1, F1, F1, F0, F1),
    (F1, F0, F1, F1, F1, F0, F1),
    (F1, F0, F1, F1, F1, F0, F1),
    (F1, F0, F0, F0, F0, F0, F1),
    (F1, F1, F1, F1, F1, F1, F1)
  );

  { 位置合わせパターンのデータ }
  alignpattern: array[0..QR_DIM_ALIGN - 1, 0..QR_DIM_ALIGN - 1] of Byte = (
    (F1, F1, F1, F1, F1),
    (F1, F0, F0, F0, F1),
    (F1, F0, F1, F0, F1),
    (F1, F0, F0, F0, F1),
    (F1, F1, F1, F1, F1)
  );

  { モード指示子(英字, 英数字, 8ビットバイト, 漢字) }
  modeid: array[0..QR_EM_MAX - 1] of Word = ($01, $02, $04, $08);

  { 英数字モードの符号化表 }
  alnumtable: array[0..127] of Shortint = (
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    36, -1, -1, -1, 37, 38, -1, -1, -1, -1, 39, 40, -1, 41, 42, 43,
     0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 44, -1, -1, -1, -1, -1,
    -1, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
    25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
  );

  EN = QR_EM_NUMERIC;
  EA = QR_EM_ALNUM;
  E8 = QR_EM_8BIT;
  EK = QR_EM_KANJI;

  { 文字クラス表 }
  charclass: array[0..255] of Shortint = (
    E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8,
    E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8,
    EA, E8, E8, E8, EA, EA, E8, E8, E8, E8, EA, EA, E8, EA, EA, EA,
    EN, EN, EN, EN, EN, EN, EN, EN, EN, EN, EA, E8, E8, E8, E8, E8,
    E8, EA, EA, EA, EA, EA, EA, EA, EA, EA, EA, EA, EA, EA, EA, EA,
    EA, EA, EA, EA, EA, EA, EA, EA, EA, EA, EA, E8, E8, E8, E8, E8,
    E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8,
    E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8,
    E8, EK, EK, EK, EK, EK, EK, EK, EK, EK, EK, EK, EK, EK, EK, EK,
    EK, EK, EK, EK, EK, EK, EK, EK, EK, EK, EK, EK, EK, EK, EK, EK,
    E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8,
    E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8,
    E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8,
    E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8,
    EK, EK, EK, EK, EK, EK, EK, EK, EK, EK, EK, EK, E8, E8, E8, E8,
    E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8, E8
  );

type
  { 座標データ型 }
  COORD = record
    ypos: Integer;
    xpos: Integer;
  end;

const
  { 形式情報(2箇所)の座標(下位ビットから) }
  { (負数は下端/右端からのオフセット) }
  fmtinfopos: array[0..1, 0..QR_FIN_MAX - 1] of COORD = (
    ((ypos:  0; xpos:  8), (ypos: 1;  xpos:  8), (ypos:  2; xpos:  8),
     (ypos:  3; xpos:  8), (ypos: 4;  xpos:  8), (ypos:  5; xpos:  8),
     (ypos:  7; xpos:  8), (ypos: 8;  xpos:  8), (ypos: -7; xpos:  8),
     (ypos: -6; xpos:  8), (ypos: -5; xpos:  8), (ypos: -4; xpos:  8),
     (ypos: -3; xpos:  8), (ypos: -2; xpos:  8), (ypos: -1; xpos:  8)),
    ((ypos:  8; xpos: -1), (ypos: 8;  xpos: -2), (ypos:  8; xpos: -3),
     (ypos:  8; xpos: -4), (ypos: 8;  xpos: -5), (ypos:  8; xpos: -6),
     (ypos:  8; xpos: -7), (ypos: 8;  xpos: -8), (ypos:  8; xpos:  7),
     (ypos:  8; xpos:  5), (ypos: 8;  xpos:  4), (ypos:  8; xpos:  3),
     (ypos:  8; xpos:  2), (ypos: 8;  xpos:  1), (ypos:  8; xpos:  0))
  );

  { 形式情報の固定黒モジュール }
  fmtblackpos: COORD = (ypos: -8; xpos: 8);

  { 型番情報(2箇所)の座標(下位ビットから) }
  { (負数は下端/右端からのオフセット) }
  verinfopos: array[0..1, 0..QR_VIN_MAX - 1] of COORD = (
    ((ypos: -11; xpos: 0),   (ypos: -10; xpos:  0),  (ypos: -9; xpos:  0),
     (ypos: -11; xpos: 1),   (ypos: -10; xpos:  1),  (ypos: -9; xpos:  1),
     (ypos: -11; xpos: 2),   (ypos: -10; xpos:  2),  (ypos: -9; xpos:  2),
     (ypos: -11; xpos: 3),   (ypos: -10; xpos:  3),  (ypos: -9; xpos:  3),
     (ypos: -11; xpos: 4),   (ypos: -10; xpos:  4),  (ypos: -9; xpos:  4),
     (ypos: -11; xpos: 5),   (ypos: -10; xpos:  5),  (ypos: -9; xpos:  5 )),
    ((ypos:  0;  xpos: -11), (ypos:   0; xpos: -10), (ypos:  0; xpos: -9),
     (ypos:  1;  xpos: -11), (ypos:   1; xpos: -10), (ypos:  1; xpos: -9),
     (ypos:  2;  xpos: -11), (ypos:   2; xpos: -10), (ypos:  2; xpos: -9),
     (ypos:  3;  xpos: -11), (ypos:   3; xpos: -10), (ypos:  3; xpos: -9),
     (ypos:  4;  xpos: -11), (ypos:   4; xpos: -10), (ypos:  4; xpos: -9),
     (ypos:  5;  xpos: -11), (ypos:   5; xpos: -10), (ypos:  5; xpos: -9))
  );

  { 型番情報(型番7～40について有効) }
  verinfo: array[0..QR_VER_MAX] of Longint = (
        -1,     -1,     -1,     -1,     -1,     -1,
        -1, $07C94, $085BC, $09A99, $0A4D3, $0BBF6,
    $0C762, $0D847, $0E60D, $0F928, $10B78, $1145D,
    $12A17, $13532, $149A6, $15683, $168C9, $177EC,
    $18EC4, $191E1, $1AFAB, $1B08E, $1CC1A, $1D33F,
    $1ED75, $1F250, $209D5, $216F0, $228BA, $2379F,
    $24B0B, $2542E, $26A64, $27541, $28C69
  );

type
  TSymbolPictures = (psymBMP, psymEMF, psymWMF);

  TLocations = (locsLeft, locsCenter, locsRight);

  { TQRCode クラス }
  TQRCode = class(TImage)
  private
    { Private 宣言 }
    FCode: String;
    FCommentUp: String;
    FCommentUpLoc: TLocations;
    FCommentDown: String;
    FCommentDownLoc: TLocations;
    FSymbolLeft: Integer;
    FSymbolTop: Integer;
    FSymbolSpaceUp: Integer;
    FSymbolSpaceDown: Integer;
    FSymbolSpaceLeft: Integer;
    FSymbolSpaceRight: Integer;
    FVersion: Integer;  // 型番
    FEmode: Integer;    // 符号化モード
    FEmodeR: Integer;
    FEclevel: Integer;  // 誤り訂正レベル
    FMasktype: Integer; // マスクパターン種別
    FMasktypeR: Integer;
    FPxmag: Integer;    // 表示画素倍率
    FPBM: TStringList;  // Portable Bitmap
    FMatch: Boolean;
    FComFont: TFont;
    FTransparent: Boolean;
    FSymbolColor: TColor;
    FBackColor: TColor;
    FSymbolPicture: TSymbolPictures;
    FSymbolEnabled: Boolean;
    FSymbolDebug: Boolean;        // デバッグ用プロパティ
    FSymbolDisped: Boolean;
    FClearOption: Boolean;
    FMfCanvas: TMetafileCanvas;   // メタファイル用キャンバス
    FWindowHandle: HWND;
    FNextWindowHandle: HWND;
    FRegistered: Boolean;
    FClipWatch: Boolean;            // クリップボード監視用のスイッチ
    FOnPaintSymbol: TNotifyEvent;   // OnPaintSymbol イベントフィールド
    FOnPaintedSymbol: TNotifyEvent; // OnPaintedSymbol イベントフィールド
    FOnClipChange: TNotifyEvent;    // OnClipChange イベントフィールド
    FSkip: Boolean; // 最初の OnClipChange イベントをスキップする為のフラッグ
    { データ領域 }
    vertable: array[0..QR_VER_MAX] of QR_VERTABLE; // 型番データ表
    source: array[0..QR_SRC_MAX - 1] of Byte;      // 入力データ領域
    dataword: array[0..QR_DWD_MAX - 1] of Byte;    // データコード語領域
    ecword: array[0..QR_ECW_MAX - 1] of Byte;      // 誤り訂正コード語領域
    codeword: array[0..QR_CWD_MAX - 1] of Byte;    // シンボル配置用コード語領域
    rswork: array[0..QR_RSD_MAX - 1] of Byte;      // RS符号計算用作業領域
    symbol: array[0..QR_DIM_MAX - 1, 0..QR_DIM_MAX - 1] of Byte; // シンボルデータ領域
    { その他の大域変数 }
    srclen: Integer;     // 入力データのバイト長
    dwpos: Integer;      // データコード語の追加バイト位置
    dwbit: Integer;      // データコード語の追加ビット位置
    xpos, ypos: Integer; // モジュールを配置する座標位置
    xdir, ydir: Integer; // モジュール配置の移動方向
    function GetSymbolWidth: Integer;
    function GetSymbolHeight: Integer;
    function GetQuietZone: Integer;
    function GetCapacity: Integer;
    function GetPBM: TStringList;
    procedure SetCode(const Value: String);
    procedure SetCommentUp(const Value: String);
    procedure SetCommentUpLoc(const Value: TLocations);
    procedure SetCommentDown(const Value: String);
    procedure SetCommentDownLoc(const Value: TLocations);
    procedure SetSymbolLeft(const Value: Integer);
    procedure SetSymbolTop(const Value: Integer);
    procedure SetSymbolSpaceUp(const Value: Integer);
    procedure SetSymbolSpaceDown(const Value: Integer);
    procedure SetSymbolSpaceLeft(const Value: Integer);
    procedure SetSymbolSpaceRight(const Value: Integer);
    procedure SetVersion(const Value: Integer);
    procedure SetEmode(const Value: Integer);
    procedure SetEclevel(const Value: Integer);
    procedure SetMasktype(const Value: Integer);
    procedure SetPxmag(const Value: Integer);
    procedure SetMatch(const Value: Boolean);
    procedure SetComFont(const Value: TFont);
    procedure SetTransparent(const Value: Boolean);
    procedure SetSymbolColor(const Value: TColor);
    procedure SetBackColor(const Value: TColor);
    procedure SetSymbolPicture(const Value: TSymbolPictures);
    procedure SetSymbolEnabled(const Value: Boolean);
    procedure SetSymbolDebug(const Value: Boolean);
    procedure SetClearOption(const Value: Boolean);
    procedure SetClipWatch(const Value: Boolean);
    procedure SetOnClipChange(const Value: TNotifyEvent);
    { ローカル関数群 }
    procedure PaintSymbolCodeB;
    procedure PaintSymbolCodeM;
    procedure SaveToClipAsWMF(const mf: TMetafile);
    procedure WndClipProc(var Message: TMessage);
    procedure UpdateClip;
    procedure ClipChangeHandler(Sender: TObject);
    function isData(i, j: Integer): Boolean;
    function isBlack(i, j: Integer): Boolean;
    function isFunc(i, j: Integer): Boolean;
    procedure initvertable;
    function qrEncodeDataWordA: Integer;
    function qrEncodeDataWordM: Integer;
    procedure qrInitDataWord;
    function qrGetSourceRegion(src: PByte; len: Integer; var mode: Integer): Integer;
    function qrGetEncodedLength(mode: Integer; len: Integer): Integer;
    procedure qrAddDataBits(n: Integer; w: Longword);
    function qrRemainedDataBits: Integer;
    procedure qrComputeECWord;
    procedure qrMakeCodeWord;
    procedure qrFillFunctionPattern;
    procedure qrFillCodeWord;
    procedure qrInitPosition;
    procedure qrNextPosition;
    procedure qrSelectMaskPattern;
    procedure qrSetMaskPattern(mask: Integer);
    function qrEvaluateMaskPattern: Longint;
    procedure qrFillFormatInfo;
    procedure qrOutputSymbol;
  protected
    { Protected 宣言 }
    procedure PaintSymbolCode; virtual;
    { イベントメソッド宣言 }
    procedure PaintSymbol; dynamic;
    procedure PaintedSymbol; dynamic;
    procedure ClipChange; dynamic;
  public
    { Public 宣言 }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { 公開メソッド宣言 }
    procedure Clear; virtual;
    procedure CopyToClipboard; virtual;
    procedure PasteFromClipboard; virtual;
    procedure RepaintSymbol; virtual;
    { イベント宣言 }
    property OnClipChange: TNotifyEvent read FOnClipChange write SetOnClipChange;
  published
    { Published 宣言(プロパティ宣言) }
    property Code: String read FCode write SetCode nodefault;
    property CommentUp: String read FCommentUp write SetCommentUp nodefault;
    property CommentUpLoc: TLocations read FCommentUpLoc write SetCommentUpLoc nodefault;
    property CommentDown: String read FCommentDown write SetCommentDown nodefault;
    property CommentDownLoc: TLocations read FCommentDownLoc write SetCommentDownLoc nodefault;
    property SymbolWidth: Integer read GetSymbolWidth;
    property SymbolHeight: Integer read GetSymbolHeight;
    property QuietZone: Integer read GetQuietZone;
    property SymbolLeft: Integer read FSymbolLeft write SetSymbolLeft nodefault;
    property SymbolTop: Integer read FSymbolTop write SetSymbolTop nodefault;
    property SymbolSpaceUp: Integer read FSymbolSpaceUp write SetSymbolSpaceUp nodefault;
    property SymbolSpaceDown: Integer read FSymbolSpaceDown write SetSymbolSpaceDown nodefault;
    property SymbolSpaceLeft: Integer read FSymbolSpaceLeft write SetSymbolSpaceLeft nodefault;
    property SymbolSpaceRight: Integer read FSymbolSpaceRight write SetSymbolSpaceRight nodefault;
    property Version: Integer read FVersion write SetVersion default 1;
    property Emode: Integer read FEmode write SetEmode default -1;
    property EmodeR: Integer read FEmodeR nodefault;
    property Eclevel: Integer read FEclevel write SetEclevel default 0;
    property Masktype: Integer read FMasktype write SetMasktype default -1;
    property MasktypeR: Integer read FMasktypeR nodefault;
    property Capacity: Integer read GetCapacity;
    property Pxmag: Integer read FPxmag write SetPxmag default 1;
    property PBM: TStringList read GetPBM;
    property Match: Boolean read FMatch write SetMatch nodefault;
    property ComFont: TFont read FComFont write SetComFont stored True;
    property Transparent: Boolean read FTransparent write SetTransparent nodefault;
    property SymbolColor: TColor read FSymbolColor write SetSymbolColor default clBlack;
    property BackColor: TColor read FBackColor write SetBackColor default clWhite;
    property SymbolPicture: TSymbolPictures read FSymbolPicture write SetSymbolPicture default psymBMP;
    property SymbolEnabled: Boolean read FSymbolEnabled write SetSymbolEnabled default True;
    property SymbolDebug: Boolean read FSymbolDebug write SetSymbolDebug nodefault;
    property SymbolDisped: Boolean read FSymbolDisped nodefault;
    property ClearOption: Boolean read FClearOption write SetClearOption default False;
    property ClipWatch: Boolean read FClipWatch write SetClipWatch default False;
    { イベント宣言 }
    property OnPaintSymbol: TNotifyEvent read FOnPaintSymbol write FOnPaintSymbol;
    property OnPaintedSymbol: TNotifyEvent read FOnPaintedSymbol write FOnPaintedSymbol;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('ToolBox', [TQRCode]);
end;

constructor TQRCode.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCode := '';
  FCommentUp := '';
  FCommentUpLoc := locsLeft;
  FCommentDown := '';
  FCommentDownLoc := locsLeft;
  FSymbolLeft := 0;
  FSymbolTop := 0;
  FSymbolSpaceUp := 0;
  FSymbolSpaceDown := 0;
  FSymbolSpaceLeft := 0;
  FSymbolSpaceRight := 0;
  FVersion := 1;
  FEmode := -1;         // 自動判定
  FEmodeR := FEmode;
  FEclevel := QR_ECL_L; // = 0(レベルL)
  FMasktype := -1;      // 自動設定
  FMasktypeR := FMasktype;
  FPxmag := 1;
  FPBM := TStringList.Create; FPBM.Duplicates := dupAccept;
  FMatch := False;
  FTransparent := False;
  FComFont := TFont.Create;
  FSymbolColor := clBlack;
  FBackColor := clWhite;
  FSymbolPicture := psymBMP;
  FSymbolEnabled := True;
  FSymbolDebug := False; // デバッグ用プロパティ
  FSymbolDisped := False;
  FClearOption := False;
  initvertable;
  // 2002/10/06 Modify ぜえた From Here
  FWindowHandle := AllocateHWnd(WndClipProc);
  FClipWatch := False;
  OnClipChange := ClipChangeHandler; // メソッドをイベントにアタッチする。
  FSkip := False; // 最初の OnClipChange イベントをスキップする為のフラッグ
  // 2002/10/06 Modify ぜえた Until Here
end;

destructor TQRCode.Destroy;
begin
  // 2002/10/06 Modify ぜえた From Here
  SetClipWatch(False);
  DeallocateHWnd(FWindowHandle);
  // 2002/10/06 Modify ぜえた Until Here
  FComFont.Free;
  FPBM.Free;
  inherited Destroy;
end;

{ 現在 Picture が、保持しているグラフイックデータを破棄して Canvas を }
{ クリアーするメソッドです。このとき SymbolDisped プロパティは False }
{ に設定されます。}
procedure TQRCode.Clear;
begin
  if FSymbolDisped = True then
    FSymbolDisped := False;

  Picture := Nil; // グラフイックデータを破棄
end;

{ 2002/10/06 Update ぜえた From Here }
procedure TQRCode.ClipChange; // イベントメソッド
begin
  if Assigned(FOnClipChange) then
    FOnClipChange(Self);      // イベントハンドラの呼び出し
end;

procedure TQRCode.ClipChangeHandler(Sender: TObject);
begin
  if FSkip = True then // 最初に発生した OnClipChange イベントをスキップする。
  begin
    FSkip := False;
    Exit;
  end;

  PasteFromClipboard;
end;
{ 2002/10/06 Update ぜえた Until Here }

procedure TQRCode.CopyToClipboard;
begin
  { まだ一度もバーコードを表示していないか、表示に失敗した場合は、Bitmap や }
  { Metafile あるいはそれ以外の形式で画像が表示されている可能性もあるので }
  { 可能な限りコピーを試みます。}
  if FSymbolDisped = False then
    Clipboard.Assign(Picture)
  else if FSymbolPicture = psymBMP then // ビットマップ形式でコピー
    Clipboard.Assign(Picture.Bitmap)
  else if FSymbolPicture = psymEMF then // EMF形式でコピー
    Clipboard.Assign(Picture.Metafile)  // (Win32 エンハンスドメタファイル)
  else                                  // WMF形式でコピー
    SaveToClipAsWMF(Picture.Metafile);  // (Win16 形式メタファイル)
end;

function TQRCode.GetCapacity: Integer;
var
  em: Integer;
begin
  em := FEmodeR;
  if em = -1 then
    em := QR_EM_ALNUM; // この場合は、暫定的に英数字モードの値を返す。
  Result := vertable[FVersion].ecl[FEclevel].capacity[em];
end;

function TQRCode.GetPBM: TStringList;
begin
  qrOutputSymbol;
  Result := FPBM;
end;

function TQRCode.GetQuietZone: Integer;
begin
  Result := QR_DIM_SEP * FPxmag;
end;

function TQRCode.GetSymbolHeight: Integer;
begin
  Result := (vertable[FVersion].dimension + QR_DIM_SEP * 2) * FPxmag;
end;

function TQRCode.GetSymbolWidth: Integer;
begin
  Result := (vertable[FVersion].dimension + QR_DIM_SEP * 2) * FPxmag;
end;

procedure TQRCode.initvertable;
const
  { vertable 初期化用データ領域 }
  capacities: array[1..40, 0..3, 0..3] of Integer = (
    // version 1 (capacities[1][0] ～capacities[1][3])
    ((41, 25, 17, 10), (34, 20, 14, 8), (27, 16, 11, 7), (17, 10, 7, 4)),
    // version 2
    ((77, 47, 32, 20), (63, 38, 26, 16), (48, 29, 20, 12), (34, 20, 14, 8)),
    // version 3
    ((127, 77, 53, 32), (101, 61, 42, 26), (77, 47, 32, 20), (58, 35, 24, 15)),
    // version 4
    ((187, 114, 78, 48), (149, 90, 62, 38), (111, 67, 46, 28), (82, 50, 34, 21)),
    // version 5
    ((255, 154, 106, 65), (202, 122, 84, 52), (144, 87, 60, 37), (106, 64, 44, 27)),
    // version 6
    ((322, 195, 134, 82), (255, 154, 106, 65), (178, 108, 74, 45), (139, 84, 58, 36)),
    // version 7
    ((370, 224, 154, 95), (293, 178, 122, 75), (207, 125, 86, 53), (154, 93, 64, 39)),
    // version 8
    ((461, 279, 192, 118), (365, 221, 152, 93), (259, 157, 108, 66), (202, 122, 84, 52)),
    // version 9
    ((552, 335, 230, 141), (432, 262, 180, 111), (312, 189, 130, 80), (235, 143, 98, 60)),
    // version 10
    ((652, 395, 271, 167), (513, 311, 213, 131), (364, 221, 151, 93), (288, 174, 119, 74)),
    // version 11
    ((772, 468, 321, 198), (604, 366, 251, 155), (427, 259, 177, 109), (331, 200, 137, 85)),
    // version 12
    ((883, 535, 367, 226), (691, 419, 287, 177), (489, 296, 203, 125), (374, 227, 155, 96)),
    // version 13
    ((1022, 619, 425, 262), (796, 483, 331, 204), (580, 352, 241, 149), (427, 259, 177, 109)),
    // version 14
    ((1101, 667, 458, 282), (871, 528, 362, 223), (621, 376, 258, 159), (468, 283, 194, 120)),
    // version 15
    ((1250, 758, 520, 320), (991, 600, 412, 254), (703, 426, 292, 180), (530, 321, 220, 136)),
    // version 16
    ((1408, 854, 586, 361), (1082, 656, 450, 277), (775, 470, 322, 198), (602, 365, 250, 154)),
    // version 17
    ((1548, 938, 644, 397), (1212, 734, 504, 310), (876, 531, 364, 224), (674, 408, 280, 173)),
    // version 18
    ((1725, 1046, 718, 442), (1346, 816, 560, 345), (948, 574, 394, 243), (746, 452, 310, 191)),
    // version 19
    ((1903, 1153, 792, 488), (1500, 909, 624, 384), (1063, 644, 442, 272), (813, 493, 338, 208)),
    // version 20
    ((2061, 1249, 858, 528), (1600, 970, 666, 410), (1159, 702, 482, 297), (919, 557, 382, 235)),
    // version 21
    ((2232, 1352, 929, 572), (1708, 1035, 711, 438), (1224, 742, 509, 314), (969, 587, 403, 248)),
    // version 22
    ((2409, 1460, 1003, 618), (1872, 1134, 779, 480), (1358, 823, 565, 348), (1056, 640, 439, 270)),
    // version 23
    ((2620, 1588, 1091, 672), (2059, 1248, 857, 528), (1468, 890, 611, 376), (1108, 672, 461, 284)),
    // version 24
    ((2812, 1704, 1171, 721), (2188, 1326, 911, 561), (1588, 963, 661, 407), (1228, 744, 511, 315)),
    // version 25
    ((3057, 1853, 1273, 784), (2395, 1451, 997, 614), (1718, 1041, 715, 440), (1286, 779, 535, 330)),
    // version 26
    ((3283, 1990, 1367, 842), (2544, 1542, 1059, 652), (1804, 1094, 751, 462), (1425, 864, 593, 365)),
    // version 27
    ((3517, 2132, 1465, 902), (2701, 1637, 1125, 692), (1933, 1172, 805, 496), (1501, 910, 625, 385)),
    // version 28
    ((3669, 2223, 1528, 940), (2857, 1732, 1190, 732), (2085, 1263, 868, 534), (1581, 958, 658, 405)),
    // version 29
    ((3909, 2369, 1628, 1002), (3035, 1839, 1264, 778), (2181, 1322, 908, 559), (1677, 1016, 698, 430)),
    // version 30
    ((4158, 2520, 1732, 1066), (3289, 1994, 1370, 843), (2358, 1429, 982, 604), (1782, 1080, 742, 457)),
    // version 31
    ((4417, 2677, 1840, 1132), (3486, 2113, 1452, 894), (2473, 1499, 1030, 634), (1897, 1150, 790, 486)),
    // version 32
    ((4686, 2840, 1952, 1201), (3693, 2238, 1538, 947), (2670, 1618, 1112, 684), (2022, 1226, 842, 518)),
    // version 33
    ((4965, 3009, 2068, 1273), (3909, 2369, 1628, 1002), (2805, 1700, 1168, 719), (2157, 1307, 898, 553)),
    // version 34
    ((5253, 3183, 2188, 1347), (4134, 2506, 1722, 1060), (2949, 1787, 1228, 756), (2301, 1394, 958, 590)),
    // version 35
    ((5529, 3351, 2303, 1417), (4343, 2632, 1809, 1113), (3081, 1867, 1283, 790), (2361, 1431, 983, 605)),
    // version 36
    ((5836, 3537, 2431, 1496), (4588, 2780, 1911, 1176), (3244, 1966, 1351, 832), (2524, 1530, 1051, 647)),
    // version 37
    ((6153, 3729, 2563, 1577), (4775, 2894, 1989, 1224), (3417, 2071, 1423, 876), (2625, 1591, 1093, 673)),
    // version 38
    ((6479, 3927, 2699, 1661), (5039, 3054, 2099, 1292), (3599, 2181, 1499, 923), (2735, 1658, 1139, 701)),
    // version 39
    ((6743, 4087, 2809, 1729), (5313, 3220, 2213, 1362), (3791, 2298, 1579, 972), (2927, 1774, 1219, 750)),
    // version 40
    ((7089, 4296, 2953, 1817), (5596, 3391, 2331, 1435), (3993, 2420, 1663, 1024), (3057, 1852, 1273, 784))
  );

  rsbs: array[0..287] of QR_RSBLOCK = (
    // version 1 (rsbs[0]～rsbs[3])
    (rsbnum: 1; totalwords: 26; datawords: 19; ecnum: 2),
    (rsbnum: 1; totalwords: 26; datawords: 16; ecnum: 4),
    (rsbnum: 1; totalwords: 26; datawords: 13; ecnum: 6),
    (rsbnum: 1; totalwords: 26; datawords: 9; ecnum: 8),
    // version 2 (rsbs[4]～rsbs[7])
    (rsbnum: 1; totalwords: 44; datawords: 34; ecnum: 4),
    (rsbnum: 1; totalwords: 44; datawords: 28; ecnum: 8),
    (rsbnum: 1; totalwords: 44; datawords: 22; ecnum: 11),
    (rsbnum: 1; totalwords: 44; datawords: 16; ecnum: 14),
    // version 3 (rsbs[8]～rsbs[11])
    (rsbnum: 1; totalwords: 70; datawords: 55; ecnum: 7),
    (rsbnum: 1; totalwords: 70; datawords: 44; ecnum: 13),
    (rsbnum: 2; totalwords: 35; datawords: 17; ecnum: 9),
    (rsbnum: 2; totalwords: 35; datawords: 13; ecnum: 11),
    // version 4 (rsbs[12]～rsbs[15])
    (rsbnum: 1; totalwords: 100; datawords: 80; ecnum: 10),
    (rsbnum: 2; totalwords: 50; datawords: 32; ecnum: 9),
    (rsbnum: 2; totalwords: 50; datawords: 24; ecnum: 13),
    (rsbnum: 4; totalwords: 25; datawords: 9; ecnum: 8),
    // version 5 (rsbs[16]～rsbs[21])
    (rsbnum: 1; totalwords: 134; datawords: 108; ecnum: 13),
    (rsbnum: 2; totalwords: 67; datawords: 43; ecnum: 12),
    (rsbnum: 2; totalwords: 33; datawords: 15; ecnum: 9), (rsbnum: 2; totalwords: 34; datawords: 16; ecnum: 9),
    (rsbnum: 2; totalwords: 33; datawords: 11; ecnum: 11), (rsbnum: 2; totalwords: 34; datawords: 12; ecnum: 11),
    // version 6 (rsbs[22]～rsbs[25])
    (rsbnum: 2; totalwords: 86; datawords: 68; ecnum: 9),
    (rsbnum: 4; totalwords: 43; datawords: 27; ecnum: 8),
    (rsbnum: 4; totalwords: 43; datawords: 19; ecnum: 12),
    (rsbnum: 4; totalwords: 43; datawords: 15; ecnum: 14),
    // version 7 (rsbs[26]～rsbs[31])
    (rsbnum: 2; totalwords: 98; datawords: 78; ecnum: 10),
    (rsbnum: 4; totalwords: 49; datawords: 31; ecnum: 9),
    (rsbnum: 2; totalwords: 32; datawords: 14; ecnum: 9), (rsbnum: 4; totalwords: 33; datawords: 15; ecnum: 9),
    (rsbnum: 4; totalwords: 39; datawords: 13; ecnum: 13), (rsbnum: 1; totalwords: 40; datawords: 14; ecnum: 13),
    // version 8 (rsbs[32]～rsbs[38])
    (rsbnum: 2; totalwords: 121; datawords: 97; ecnum: 12),
    (rsbnum: 2; totalwords: 60; datawords: 38; ecnum: 11), (rsbnum: 2; totalwords: 61; datawords: 39; ecnum: 11),
    (rsbnum: 4; totalwords: 40; datawords: 18; ecnum: 11), (rsbnum: 2; totalwords: 41; datawords: 19; ecnum: 11),
    (rsbnum: 4; totalwords: 40; datawords: 14; ecnum: 13), (rsbnum: 2; totalwords: 41; datawords: 15; ecnum: 13),
    // version 9 (rsbs[39]～rsbs[45])
    (rsbnum: 2; totalwords: 146; datawords: 116; ecnum: 15),
    (rsbnum: 3; totalwords: 58; datawords: 36; ecnum: 11), (rsbnum: 2; totalwords: 59; datawords: 37; ecnum: 11),
    (rsbnum: 4; totalwords: 36; datawords: 16; ecnum: 10), (rsbnum: 4; totalwords: 37; datawords: 17; ecnum: 10),
    (rsbnum: 4; totalwords: 36; datawords: 12; ecnum: 12), (rsbnum: 4; totalwords: 37; datawords: 13; ecnum: 12),
    // version 10 (rsbs[46]～rsbs[53])
    (rsbnum: 2; totalwords: 86; datawords: 68; ecnum: 9), (rsbnum: 2; totalwords: 87; datawords: 69; ecnum: 9),
    (rsbnum: 4; totalwords: 69; datawords: 43; ecnum: 13), (rsbnum: 1; totalwords: 70; datawords: 44; ecnum: 13),
    (rsbnum: 6; totalwords: 43; datawords: 19; ecnum: 12), (rsbnum: 2; totalwords: 44; datawords: 20; ecnum: 12),
    (rsbnum: 6; totalwords: 43; datawords: 15; ecnum: 14), (rsbnum: 2; totalwords: 44; datawords: 16; ecnum: 14),
    // version 11 (rsbs[54]～rsbs[60])
    (rsbnum: 4; totalwords: 101; datawords: 81; ecnum: 10),
    (rsbnum: 1; totalwords: 80; datawords: 50; ecnum: 15), (rsbnum: 4; totalwords: 81; datawords: 51; ecnum: 15),
    (rsbnum: 4; totalwords: 50; datawords: 22; ecnum: 14), (rsbnum: 4; totalwords: 51; datawords: 23; ecnum: 14),
    (rsbnum: 3; totalwords: 36; datawords: 12; ecnum: 12), (rsbnum: 8; totalwords: 37; datawords: 13; ecnum: 12),
    // version 12 (rsbs[61]～rsbs[68])
    (rsbnum: 2; totalwords: 116; datawords: 92; ecnum: 12), (rsbnum: 2; totalwords: 117; datawords: 93; ecnum: 12),
    (rsbnum: 6; totalwords: 58; datawords: 36; ecnum: 11), (rsbnum: 2; totalwords: 59; datawords: 37; ecnum: 11),
    (rsbnum: 4; totalwords: 46; datawords: 20; ecnum: 13), (rsbnum: 6; totalwords: 47; datawords: 21; ecnum: 13),
    (rsbnum: 7; totalwords: 42; datawords: 14; ecnum: 14), (rsbnum: 4; totalwords: 43; datawords: 15; ecnum: 14),
    // version 13 (rsbs[69]～rsbs[75])
    (rsbnum: 4; totalwords: 133; datawords: 107; ecnum: 13),
    (rsbnum: 8; totalwords: 59; datawords: 37; ecnum: 11), (rsbnum: 1; totalwords: 60; datawords: 38; ecnum: 11),
    (rsbnum: 8; totalwords: 44; datawords: 20; ecnum: 12), (rsbnum: 4; totalwords: 45; datawords: 21; ecnum: 12),
    (rsbnum: 12; totalwords: 33; datawords: 11; ecnum: 11), (rsbnum: 4; totalwords: 34; datawords: 12; ecnum: 11),
    // version 14 (rsbs[76]～rsbs[83])
    (rsbnum: 3; totalwords: 145; datawords: 115; ecnum: 15), (rsbnum: 1; totalwords: 146; datawords: 116; ecnum: 15),
    (rsbnum: 4; totalwords: 64; datawords: 40; ecnum: 12), (rsbnum: 5; totalwords: 65; datawords: 41; ecnum: 12),
    (rsbnum: 11; totalwords: 36; datawords: 16; ecnum: 10), (rsbnum: 5; totalwords: 37; datawords: 17; ecnum: 10),
    (rsbnum: 11; totalwords: 36; datawords: 12; ecnum: 12), (rsbnum: 5; totalwords: 37; datawords: 13; ecnum: 12),
    // version 15 (rsbs[84]～rsbs[91])
    (rsbnum: 5; totalwords: 109; datawords: 87; ecnum: 11), (rsbnum: 1; totalwords: 110; datawords: 88; ecnum: 11),
    (rsbnum: 5; totalwords: 65; datawords: 41; ecnum: 12), (rsbnum: 5; totalwords: 66; datawords: 42; ecnum: 12),
    (rsbnum: 5; totalwords: 54; datawords: 24; ecnum: 15), (rsbnum: 7; totalwords: 55; datawords: 25; ecnum: 15),
    (rsbnum: 11; totalwords: 36; datawords: 12; ecnum: 12), (rsbnum: 7; totalwords: 37; datawords: 13; ecnum: 12),
    // version 16 (rsbs[92]～rsbs[99])
    (rsbnum: 5; totalwords: 122; datawords: 98; ecnum: 12), (rsbnum: 1; totalwords: 123; datawords: 99; ecnum: 12),
    (rsbnum: 7; totalwords: 73; datawords: 45; ecnum: 14), (rsbnum: 3; totalwords: 74; datawords: 46; ecnum: 14),
    (rsbnum: 15; totalwords: 43; datawords: 19; ecnum: 12), (rsbnum: 2; totalwords: 44; datawords: 20; ecnum: 12),
    (rsbnum: 3; totalwords: 45; datawords: 15; ecnum: 15), (rsbnum: 13; totalwords: 46; datawords: 16; ecnum: 15),
    // version 17 (rsbs[100]～rsbs[107])
    (rsbnum: 1; totalwords: 135; datawords: 107; ecnum: 14), (rsbnum: 5; totalwords: 136; datawords: 108; ecnum: 14),
    (rsbnum: 10; totalwords: 74; datawords: 46; ecnum: 14), (rsbnum: 1; totalwords: 75; datawords: 47; ecnum: 14),
    (rsbnum: 1; totalwords: 50; datawords: 22; ecnum: 14), (rsbnum: 15; totalwords: 51; datawords: 23; ecnum: 14),
    (rsbnum: 2; totalwords: 42; datawords: 14; ecnum: 14), (rsbnum: 17; totalwords: 43; datawords: 15; ecnum: 14),
    // version 18 (rsbs[108]～rsbs[115])
    (rsbnum: 5; totalwords: 150; datawords: 120; ecnum: 15), (rsbnum: 1; totalwords: 151; datawords: 121; ecnum: 15),
    (rsbnum: 9; totalwords: 69; datawords: 43; ecnum: 13), (rsbnum: 4; totalwords: 70; datawords: 44; ecnum: 13),
    (rsbnum: 17; totalwords: 50; datawords: 22; ecnum: 14), (rsbnum: 1; totalwords: 51; datawords: 23; ecnum: 14),
    (rsbnum: 2; totalwords: 42; datawords: 14; ecnum: 14), (rsbnum: 19; totalwords: 43; datawords: 15; ecnum: 14),
    // version 19 (rsbs[116]～rsbs[123])
    (rsbnum: 3; totalwords: 141; datawords: 113; ecnum: 14), (rsbnum: 4; totalwords: 142; datawords: 114; ecnum: 14),
    (rsbnum: 3; totalwords: 70; datawords: 44; ecnum: 13), (rsbnum: 11; totalwords: 71; datawords: 45; ecnum: 13),
    (rsbnum: 17; totalwords: 47; datawords: 21; ecnum: 13), (rsbnum: 4; totalwords: 48; datawords: 22; ecnum: 13),
    (rsbnum: 9; totalwords: 39; datawords: 13; ecnum: 13), (rsbnum: 16; totalwords: 40; datawords: 14; ecnum: 13),
    // version 20 (rsbs[124]～rsbs[131])
    (rsbnum: 3; totalwords: 135; datawords: 107; ecnum: 14), (rsbnum: 5; totalwords: 136; datawords: 108; ecnum: 14),
    (rsbnum: 3; totalwords: 67; datawords: 41; ecnum: 13), (rsbnum: 13; totalwords: 68; datawords: 42; ecnum: 13),
    (rsbnum: 15; totalwords: 54; datawords: 24; ecnum: 15), (rsbnum: 5; totalwords: 55; datawords: 25; ecnum: 15),
    (rsbnum: 15; totalwords: 43; datawords: 15; ecnum: 14), (rsbnum: 10; totalwords: 44; datawords: 16; ecnum: 14),
    // version 21 (rsbs[132]～rsbs[138])
    (rsbnum: 4; totalwords: 144; datawords: 116; ecnum: 14), (rsbnum: 4; totalwords: 145; datawords: 117; ecnum: 14),
    (rsbnum: 17; totalwords: 68; datawords: 42; ecnum: 13),
    (rsbnum: 17; totalwords: 50; datawords: 22; ecnum: 14), (rsbnum: 6; totalwords: 51; datawords: 23; ecnum: 14),
    (rsbnum: 19; totalwords: 46; datawords: 16; ecnum: 15), (rsbnum: 6; totalwords: 47; datawords: 17; ecnum: 15),
    // version 22 (rsbs[139]～rsbs[144])
    (rsbnum: 2; totalwords: 139; datawords: 111; ecnum: 14), (rsbnum: 7; totalwords: 140; datawords: 112; ecnum: 14),
    (rsbnum: 17; totalwords: 74; datawords: 46; ecnum: 14),
    (rsbnum: 7; totalwords: 54; datawords: 24; ecnum: 15), (rsbnum: 16; totalwords: 55; datawords: 25; ecnum: 15),
    (rsbnum: 34; totalwords: 37; datawords: 13; ecnum: 13),
    // version 23 (rsbs[145]～rsbs[152])
    (rsbnum: 4; totalwords: 151; datawords: 121; ecnum: 15), (rsbnum: 5; totalwords: 152; datawords: 122; ecnum: 15),
    (rsbnum: 4; totalwords: 75; datawords: 47; ecnum: 14), (rsbnum: 14; totalwords: 76; datawords: 48; ecnum: 14),
    (rsbnum: 11; totalwords: 54; datawords: 24; ecnum: 15), (rsbnum: 14; totalwords: 55; datawords: 25; ecnum: 15),
    (rsbnum: 16; totalwords: 45; datawords: 15; ecnum: 15), (rsbnum: 14; totalwords: 46; datawords: 16; ecnum: 15),
    // version 24 (rsbs[153]～rsbs[160])
    (rsbnum: 6; totalwords: 147; datawords: 117; ecnum: 15), (rsbnum: 4; totalwords: 148; datawords: 118; ecnum: 15),
    (rsbnum: 6; totalwords: 73; datawords: 45; ecnum: 14), (rsbnum: 14; totalwords: 74; datawords: 46; ecnum: 14),
    (rsbnum: 11; totalwords: 54; datawords: 24; ecnum: 15), (rsbnum: 16; totalwords: 55; datawords: 25; ecnum: 15),
    (rsbnum: 30; totalwords: 46; datawords: 16; ecnum: 15), (rsbnum: 2; totalwords: 47; datawords: 17; ecnum: 15),
    // version 25 (rsbs[161]～rsbs[168])
    (rsbnum: 8; totalwords: 132; datawords: 106; ecnum: 13), (rsbnum: 4; totalwords: 133; datawords: 107; ecnum: 13),
    (rsbnum: 8; totalwords: 75; datawords: 47; ecnum: 14), (rsbnum: 13; totalwords: 76; datawords: 48; ecnum: 14),
    (rsbnum: 7; totalwords: 54; datawords: 24; ecnum: 15), (rsbnum: 22; totalwords: 55; datawords: 25; ecnum: 15),
    (rsbnum: 22; totalwords: 45; datawords: 15; ecnum: 15), (rsbnum: 13; totalwords: 46; datawords: 16; ecnum: 15),
    // version 26 (rsbs[169]～rsbs[176])
    (rsbnum: 10; totalwords: 142; datawords: 114; ecnum: 14), (rsbnum: 2; totalwords: 143; datawords: 115; ecnum: 14),
    (rsbnum: 19; totalwords: 74; datawords: 46; ecnum: 14), (rsbnum: 4; totalwords: 75; datawords: 47; ecnum: 14),
    (rsbnum: 28; totalwords: 50; datawords: 22; ecnum: 14), (rsbnum: 6; totalwords: 51; datawords: 23; ecnum: 14),
    (rsbnum: 33; totalwords: 46; datawords: 16; ecnum: 15), (rsbnum: 4; totalwords: 47; datawords: 17; ecnum: 15),
    // version 27 (rsbs[177]～rsbs[184])
    (rsbnum: 8; totalwords: 152; datawords: 122; ecnum: 15), (rsbnum: 4; totalwords: 153; datawords: 123; ecnum: 15),
    (rsbnum: 22; totalwords: 73; datawords: 45; ecnum: 14), (rsbnum: 3; totalwords: 74; datawords: 46; ecnum: 14),
    (rsbnum: 8; totalwords: 53; datawords: 23; ecnum: 15), (rsbnum: 26; totalwords: 54; datawords: 24; ecnum: 15),
    (rsbnum: 12; totalwords: 45; datawords: 15; ecnum: 15), (rsbnum: 28; totalwords: 46; datawords: 16; ecnum: 15),
    // version 28 (rsbs[185]～rsbs[192])
    (rsbnum: 3; totalwords: 147; datawords: 117; ecnum: 15), (rsbnum: 10; totalwords: 148; datawords: 118; ecnum: 15),
    (rsbnum: 3; totalwords: 73; datawords: 45; ecnum: 14), (rsbnum: 23; totalwords: 74; datawords: 46; ecnum: 14),
    (rsbnum: 4; totalwords: 54; datawords: 24; ecnum: 15), (rsbnum: 31; totalwords: 55; datawords: 25; ecnum: 15),
    (rsbnum: 11; totalwords: 45; datawords: 15; ecnum: 15), (rsbnum: 31; totalwords: 46; datawords: 16; ecnum: 15),
    // version 29 (rsbs[193]～rsbs[200])
    (rsbnum: 7; totalwords: 146; datawords: 116; ecnum: 15), (rsbnum: 7; totalwords: 147; datawords: 117; ecnum: 15),
    (rsbnum: 21; totalwords: 73; datawords: 45; ecnum: 14), (rsbnum: 7; totalwords: 74; datawords: 46; ecnum: 14),
    (rsbnum: 1; totalwords: 53; datawords: 23; ecnum: 15), (rsbnum: 37; totalwords: 54; datawords: 24; ecnum: 15),
    (rsbnum: 19; totalwords: 45; datawords: 15; ecnum: 15), (rsbnum: 26; totalwords: 46; datawords: 16; ecnum: 15),
    // version 30 (rsbs[201]～rsbs[208])
    (rsbnum: 5; totalwords: 145; datawords: 115; ecnum: 15), (rsbnum: 10; totalwords: 146; datawords: 116; ecnum: 15),
    (rsbnum: 19; totalwords: 75; datawords: 47; ecnum: 14), (rsbnum: 10; totalwords: 76; datawords: 48; ecnum: 14),
    (rsbnum: 15; totalwords: 54; datawords: 24; ecnum: 15), (rsbnum: 25; totalwords: 55; datawords: 25; ecnum: 15),
    (rsbnum: 23; totalwords: 45; datawords: 15; ecnum: 15), (rsbnum: 25; totalwords: 46; datawords: 16; ecnum: 15),
    // version 31 (rsbs[209]～rsbs[216])
    (rsbnum: 13; totalwords: 145; datawords: 115; ecnum: 15), (rsbnum: 3; totalwords: 146; datawords: 116; ecnum: 15),
    (rsbnum: 2; totalwords: 74; datawords: 46; ecnum: 14), (rsbnum: 29; totalwords: 75; datawords: 47; ecnum: 14),
    (rsbnum: 42; totalwords: 54; datawords: 24; ecnum: 15), (rsbnum: 1; totalwords: 55; datawords: 25; ecnum: 15),
    (rsbnum: 23; totalwords: 45; datawords: 15; ecnum: 15), (rsbnum: 28; totalwords: 46; datawords: 16; ecnum: 15),
    // version 32 (rsbs[217]～rsbs[223])
    (rsbnum: 17; totalwords: 145; datawords: 115; ecnum: 15),
    (rsbnum: 10; totalwords: 74; datawords: 46; ecnum: 14), (rsbnum: 23; totalwords: 75; datawords: 47; ecnum: 14),
    (rsbnum: 10; totalwords: 54; datawords: 24; ecnum: 15), (rsbnum: 35; totalwords: 55; datawords: 25; ecnum: 15),
    (rsbnum: 19; totalwords: 45; datawords: 15; ecnum: 15), (rsbnum: 35; totalwords: 46; datawords: 16; ecnum: 15),
    // version 33 (rsbs[224]～rsbs[231])
    (rsbnum: 17; totalwords: 145; datawords: 115; ecnum: 15), (rsbnum: 1; totalwords: 146; datawords: 116; ecnum: 15),
    (rsbnum: 14; totalwords: 74; datawords: 46; ecnum: 14), (rsbnum: 21; totalwords: 75; datawords: 47; ecnum: 14),
    (rsbnum: 29; totalwords: 54; datawords: 24; ecnum: 15), (rsbnum: 19; totalwords: 55; datawords: 25; ecnum: 15),
    (rsbnum: 11; totalwords: 45; datawords: 15; ecnum: 15), (rsbnum: 46; totalwords: 46; datawords: 16; ecnum: 15),
    // version 34 (rsbs[232]～rsbs[239])
    (rsbnum: 13; totalwords: 145; datawords: 115; ecnum: 15), (rsbnum: 6; totalwords: 146; datawords: 116; ecnum: 15),
    (rsbnum: 14; totalwords: 74; datawords: 46; ecnum: 14), (rsbnum: 23; totalwords: 75; datawords: 47; ecnum: 14),
    (rsbnum: 44; totalwords: 54; datawords: 24; ecnum: 15), (rsbnum: 7; totalwords: 55; datawords: 25; ecnum: 15),
    (rsbnum: 59; totalwords: 46; datawords: 16; ecnum: 15), (rsbnum: 1; totalwords: 47; datawords: 17; ecnum: 15),
    // version 35 (rsbs[240]～rsbs[247])
    (rsbnum: 12; totalwords: 151; datawords: 121; ecnum: 15), (rsbnum: 7; totalwords: 152; datawords: 122; ecnum: 15),
    (rsbnum: 12; totalwords: 75; datawords: 47; ecnum: 14), (rsbnum: 26; totalwords: 76; datawords: 48; ecnum: 14),
    (rsbnum: 39; totalwords: 54; datawords: 24; ecnum: 15), (rsbnum: 14; totalwords: 55; datawords: 25; ecnum: 15),
    (rsbnum: 22; totalwords: 45; datawords: 15; ecnum: 15), (rsbnum: 41; totalwords: 46; datawords: 16; ecnum: 15),
    // version 36 (rsbs[248]～rsbs[255])
    (rsbnum: 6; totalwords: 151; datawords: 121; ecnum: 15), (rsbnum: 14; totalwords: 152; datawords: 122; ecnum: 15),
    (rsbnum: 6; totalwords: 75; datawords: 47; ecnum: 14), (rsbnum: 34; totalwords: 76; datawords: 48; ecnum: 14),
    (rsbnum: 46; totalwords: 54; datawords: 24; ecnum: 15), (rsbnum: 10; totalwords: 55; datawords: 25; ecnum: 15),
    (rsbnum: 2; totalwords: 45; datawords: 15; ecnum: 15), (rsbnum: 64; totalwords: 46; datawords: 16; ecnum: 15),
    // version 37 (rsbs[256]～rsbs[263])
    (rsbnum: 17; totalwords: 152; datawords: 122; ecnum: 15), (rsbnum: 4; totalwords: 153; datawords: 123; ecnum: 15),
    (rsbnum: 29; totalwords: 74; datawords: 46; ecnum: 14), (rsbnum: 14; totalwords: 75; datawords: 47; ecnum: 14),
    (rsbnum: 49; totalwords: 54; datawords: 24; ecnum: 15), (rsbnum: 10; totalwords: 55; datawords: 25; ecnum: 15),
    (rsbnum: 24; totalwords: 45; datawords: 15; ecnum: 15), (rsbnum: 46; totalwords: 46; datawords: 16; ecnum: 15),
    // version 38 (rsbs[264]～rsbs[271])
    (rsbnum: 4; totalwords: 152; datawords: 122; ecnum: 15), (rsbnum: 18; totalwords: 153; datawords: 123; ecnum: 15),
    (rsbnum: 13; totalwords: 74; datawords: 46; ecnum: 14), (rsbnum: 32; totalwords: 75; datawords: 47; ecnum: 14),
    (rsbnum: 48; totalwords: 54; datawords: 24; ecnum: 15), (rsbnum: 14; totalwords: 55; datawords: 25; ecnum: 15),
    (rsbnum: 42; totalwords: 45; datawords: 15; ecnum: 15), (rsbnum: 32; totalwords: 46; datawords: 16; ecnum: 15),
    // version 39 (rsbs[272]～rsbs[279])
    (rsbnum: 20; totalwords: 147; datawords: 117; ecnum: 15), (rsbnum: 4; totalwords: 148; datawords: 118; ecnum: 15),
    (rsbnum: 40; totalwords: 75; datawords: 47; ecnum: 14), (rsbnum: 7; totalwords: 76; datawords: 48; ecnum: 14),
    (rsbnum: 43; totalwords: 54; datawords: 24; ecnum: 15), (rsbnum: 22; totalwords: 55; datawords: 25; ecnum: 15),
    (rsbnum: 10; totalwords: 45; datawords: 15; ecnum: 15), (rsbnum: 67; totalwords: 46; datawords: 16; ecnum: 15),
    // version 40 (rsbs[280]～rsbs[287])
    (rsbnum: 19; totalwords: 148; datawords: 118; ecnum: 15), (rsbnum: 6; totalwords: 149; datawords: 119; ecnum: 15),
    (rsbnum: 18; totalwords: 75; datawords: 47; ecnum: 14), (rsbnum: 31; totalwords: 76; datawords: 48; ecnum: 14),
    (rsbnum: 34; totalwords: 54; datawords: 24; ecnum: 15), (rsbnum: 34; totalwords: 55; datawords: 25; ecnum: 15),
    (rsbnum: 20; totalwords: 45; datawords: 15; ecnum: 15), (rsbnum: 61; totalwords: 46; datawords: 16; ecnum: 15)
  );

  nlens: array[0..2, 0..3] of Integer = (
    (10, 9, 8, 8), (12, 11, 16, 10), (14, 13, 16, 12)
  );

  aplocs: array[1..40, 0..6] of Integer = (
    (0,  0,  0,  0,   0,   0,   0),
    (6, 18,  0,  0,   0,   0,   0), (6, 22,  0,  0,   0,   0,   0),
    (6, 26,  0,  0,   0,   0,   0), (6, 30,  0,  0,   0,   0,   0),
    (6, 34,  0,  0,   0,   0,   0), (6, 22, 38,  0,   0,   0,   0),
    (6, 24, 42,  0,   0,   0,   0), (6, 26, 46,  0,   0,   0,   0),
    (6, 28, 50,  0,   0,   0,   0), (6, 30, 54,  0,   0,   0,   0),
    (6, 32, 58,  0,   0,   0,   0), (6, 34, 62,  0,   0,   0,   0),
    (6, 26, 46, 66,   0,   0,   0), (6, 26, 48, 70,   0,   0,   0),
    (6, 26, 50, 74,   0,   0,   0), (6, 30, 54, 78,   0,   0,   0),
    (6, 30, 56, 82,   0,   0,   0), (6, 30, 58, 86,   0,   0,   0),
    (6, 34, 62, 90,   0,   0,   0), (6, 28, 50, 72,  94,   0,   0),
    (6, 26, 50, 74,  98,   0,   0), (6, 30, 54, 78, 102,   0,   0),
    (6, 28, 54, 80, 106,   0,   0), (6, 32, 58, 84, 110,   0,   0),
    (6, 30, 58, 86, 114,   0,   0), (6, 34, 62, 90, 118,   0,   0),
    (6, 26, 50, 74,  98, 122,   0), (6, 30, 54, 78, 102, 126,   0),
    (6, 26, 52, 78, 104, 130,   0), (6, 30, 56, 82, 108, 134,   0),
    (6, 34, 60, 86, 112, 138,   0), (6, 30, 58, 86, 114, 142,   0),
    (6, 34, 62, 90, 118, 146,   0), (6, 30, 54, 78, 102, 126, 150),
    (6, 24, 50, 76, 102, 128, 154), (6, 28, 54, 80, 106, 132, 158),
    (6, 32, 58, 84, 110, 136, 162), (6, 26, 54, 82, 110, 138, 166),
    (6, 30, 58, 86, 114, 142, 170)
  );
var
  i, j, k: Integer;
  { vertable 初期化用データ領域 }
  ecls: array[1..QR_VER_MAX, 0..QR_ECL_MAX - 1] of QR_ECLEVEL;
begin
  { ecls: array[1..QR_VER_MAX, 0..QR_ECL_MAX - 1] of QR_ECLEVEL の初期化 }
  ZeroMemory(@ecls, SizeOf(ecls));
  for i := 1 to QR_VER_MAX do
  begin
    for j := 0 to (QR_ECL_MAX - 1) do
    begin
      for k := 0 to (QR_EM_MAX - 1) do
        ecls[i][j].capacity[k] := capacities[i][j][k];
    end;
  end;
  // version 1
  ecls[1][0].datawords := 19; ecls[1][0].nrsb := 1;
  ecls[1][0].rsb[0] := rsbs[0];
  ecls[1][1].datawords := 16; ecls[1][1].nrsb := 1;
  ecls[1][1].rsb[0] := rsbs[1];
  ecls[1][2].datawords := 13; ecls[1][2].nrsb := 1;
  ecls[1][2].rsb[0] := rsbs[2];
  ecls[1][3].datawords :=  9; ecls[1][3].nrsb := 1;
  ecls[1][3].rsb[0] := rsbs[3];
  // version 2
  ecls[2][0].datawords := 34; ecls[2][0].nrsb := 1;
  ecls[2][0].rsb[0] := rsbs[4];
  ecls[2][1].datawords := 28; ecls[2][1].nrsb := 1;
  ecls[2][1].rsb[0] := rsbs[5];
  ecls[2][2].datawords := 22; ecls[2][2].nrsb := 1;
  ecls[2][2].rsb[0] := rsbs[6];
  ecls[2][3].datawords := 16; ecls[2][3].nrsb := 1;
  ecls[2][3].rsb[0] := rsbs[7];
  // version 3
  ecls[3][0].datawords := 55; ecls[3][0].nrsb := 1;
  ecls[3][0].rsb[0] := rsbs[8];
  ecls[3][1].datawords := 44; ecls[3][1].nrsb := 1;
  ecls[3][1].rsb[0] := rsbs[9];
  ecls[3][2].datawords := 34; ecls[3][2].nrsb := 1;
  ecls[3][2].rsb[0] := rsbs[10];
  ecls[3][3].datawords := 26; ecls[3][3].nrsb := 1;
  ecls[3][3].rsb[0] := rsbs[11];
  // version 4
  ecls[4][0].datawords := 80; ecls[4][0].nrsb := 1;
  ecls[4][0].rsb[0] := rsbs[12];
  ecls[4][1].datawords := 64; ecls[4][1].nrsb := 1;
  ecls[4][1].rsb[0] := rsbs[13];
  ecls[4][2].datawords := 48; ecls[4][2].nrsb := 1;
  ecls[4][2].rsb[0] := rsbs[14];
  ecls[4][3].datawords := 36; ecls[4][3].nrsb := 1;
  ecls[4][3].rsb[0] := rsbs[15];
  // version 5
  ecls[5][0].datawords := 108; ecls[5][0].nrsb := 1;
  ecls[5][0].rsb[0] := rsbs[16];
  ecls[5][1].datawords := 86; ecls[5][1].nrsb := 1;
  ecls[5][1].rsb[0] := rsbs[17];
  ecls[5][2].datawords := 62; ecls[5][2].nrsb := 2;
  ecls[5][2].rsb[0] := rsbs[18]; ecls[5][2].rsb[1] := rsbs[19];
  ecls[5][3].datawords := 46; ecls[5][3].nrsb := 2;
  ecls[5][3].rsb[0] := rsbs[20]; ecls[5][3].rsb[1] := rsbs[21];
  // version 6
  ecls[6][0].datawords := 136; ecls[6][0].nrsb := 1;
  ecls[6][0].rsb[0] := rsbs[22];
  ecls[6][1].datawords := 108; ecls[6][1].nrsb := 1;
  ecls[6][1].rsb[0] := rsbs[23];
  ecls[6][2].datawords := 76; ecls[6][2].nrsb := 1;
  ecls[6][2].rsb[0] := rsbs[24];
  ecls[6][3].datawords := 60; ecls[6][3].nrsb := 1;
  ecls[6][3].rsb[0] := rsbs[25];
  // version 7
  ecls[7][0].datawords := 156; ecls[7][0].nrsb := 1;
  ecls[7][0].rsb[0] := rsbs[26];
  ecls[7][1].datawords := 124; ecls[7][1].nrsb := 1;
  ecls[7][1].rsb[0] := rsbs[27];
  ecls[7][2].datawords := 88; ecls[7][2].nrsb := 2;
  ecls[7][2].rsb[0] := rsbs[28]; ecls[7][2].rsb[1] := rsbs[29];
  ecls[7][3].datawords := 66; ecls[7][3].nrsb := 2;
  ecls[7][3].rsb[0] := rsbs[30]; ecls[7][3].rsb[1] := rsbs[31];
  // version 8
  ecls[8][0].datawords := 194; ecls[8][0].nrsb := 1;
  ecls[8][0].rsb[0] := rsbs[32];
  ecls[8][1].datawords := 154; ecls[8][1].nrsb := 2;
  ecls[8][1].rsb[0] := rsbs[33]; ecls[8][1].rsb[1] := rsbs[34];
  ecls[8][2].datawords := 110; ecls[8][2].nrsb := 2;
  ecls[8][2].rsb[0] := rsbs[35]; ecls[8][2].rsb[1] := rsbs[36];
  ecls[8][3].datawords := 86; ecls[8][3].nrsb := 2;
  ecls[8][3].rsb[0] := rsbs[37]; ecls[8][3].rsb[1] := rsbs[38];
  // version 9
  ecls[9][0].datawords := 232; ecls[9][0].nrsb := 1;
  ecls[9][0].rsb[0] := rsbs[39];
  ecls[9][1].datawords := 182; ecls[9][1].nrsb := 2;
  ecls[9][1].rsb[0] := rsbs[40]; ecls[9][1].rsb[1] := rsbs[41];
  ecls[9][2].datawords := 132; ecls[9][2].nrsb := 2;
  ecls[9][2].rsb[0] := rsbs[42]; ecls[9][2].rsb[1] := rsbs[43];
  ecls[9][3].datawords := 100; ecls[9][3].nrsb := 2;
  ecls[9][3].rsb[0] := rsbs[44]; ecls[9][3].rsb[1] := rsbs[45];
  // version 10
  ecls[10][0].datawords := 274; ecls[10][0].nrsb := 2;
  ecls[10][0].rsb[0] := rsbs[46]; ecls[10][0].rsb[1] := rsbs[47];
  ecls[10][1].datawords := 216; ecls[10][1].nrsb := 2;
  ecls[10][1].rsb[0] := rsbs[48]; ecls[10][1].rsb[1] := rsbs[49];
  ecls[10][2].datawords := 154; ecls[10][2].nrsb := 2;
  ecls[10][2].rsb[0] := rsbs[50]; ecls[10][2].rsb[1] := rsbs[51];
  ecls[10][3].datawords := 122; ecls[10][3].nrsb := 2;
  ecls[10][3].rsb[0] := rsbs[52]; ecls[10][3].rsb[1] := rsbs[53];
  // version 11
  ecls[11][0].datawords := 324; ecls[11][0].nrsb := 1;
  ecls[11][0].rsb[0] := rsbs[54];
  ecls[11][1].datawords := 254; ecls[11][1].nrsb := 2;
  ecls[11][1].rsb[0] := rsbs[55]; ecls[11][1].rsb[1] := rsbs[56];
  ecls[11][2].datawords := 180; ecls[11][2].nrsb := 2;
  ecls[11][2].rsb[0] := rsbs[57]; ecls[11][2].rsb[1] := rsbs[58];
  ecls[11][3].datawords := 140; ecls[11][3].nrsb := 2;
  ecls[11][3].rsb[0] := rsbs[59]; ecls[11][3].rsb[1] := rsbs[60];
  // version 12
  ecls[12][0].datawords := 370; ecls[12][0].nrsb := 2;
  ecls[12][0].rsb[0] := rsbs[61]; ecls[12][0].rsb[1] := rsbs[62];
  ecls[12][1].datawords := 290; ecls[12][1].nrsb := 2;
  ecls[12][1].rsb[0] := rsbs[63]; ecls[12][1].rsb[1] := rsbs[64];
  ecls[12][2].datawords := 206; ecls[12][2].nrsb := 2;
  ecls[12][2].rsb[0] := rsbs[65]; ecls[12][2].rsb[1] := rsbs[66];
  ecls[12][3].datawords := 158; ecls[12][3].nrsb := 2;
  ecls[12][3].rsb[0] := rsbs[67]; ecls[12][3].rsb[1] := rsbs[68];
  // version 13
  ecls[13][0].datawords := 428; ecls[13][0].nrsb := 1;
  ecls[13][0].rsb[0] := rsbs[69];
  ecls[13][1].datawords := 334; ecls[13][1].nrsb := 2;
  ecls[13][1].rsb[0] := rsbs[70]; ecls[13][1].rsb[1] := rsbs[71];
  ecls[13][2].datawords := 244; ecls[13][2].nrsb := 2;
  ecls[13][2].rsb[0] := rsbs[72]; ecls[13][2].rsb[1] := rsbs[73];
  ecls[13][3].datawords := 180; ecls[13][3].nrsb := 2;
  ecls[13][3].rsb[0] := rsbs[74]; ecls[13][3].rsb[1] := rsbs[75];
  // version 14
  ecls[14][0].datawords := 461; ecls[14][0].nrsb := 2;
  ecls[14][0].rsb[0] := rsbs[76]; ecls[14][0].rsb[1] := rsbs[77];
  ecls[14][1].datawords := 365; ecls[14][1].nrsb := 2;
  ecls[14][1].rsb[0] := rsbs[78]; ecls[14][1].rsb[1] := rsbs[79];
  ecls[14][2].datawords := 261; ecls[14][2].nrsb := 2;
  ecls[14][2].rsb[0] := rsbs[80]; ecls[14][2].rsb[1] := rsbs[81];
  ecls[14][3].datawords := 197; ecls[14][3].nrsb := 2;
  ecls[14][3].rsb[0] := rsbs[82]; ecls[14][3].rsb[1] := rsbs[83];
  // version 15
  ecls[15][0].datawords := 523; ecls[15][0].nrsb := 2;
  ecls[15][0].rsb[0] := rsbs[84]; ecls[15][0].rsb[1] := rsbs[85];
  ecls[15][1].datawords := 415; ecls[15][1].nrsb := 2;
  ecls[15][1].rsb[0] := rsbs[86]; ecls[15][1].rsb[1] := rsbs[87];
  ecls[15][2].datawords := 295; ecls[15][2].nrsb := 2;
  ecls[15][2].rsb[0] := rsbs[88]; ecls[15][2].rsb[1] := rsbs[89];
  ecls[15][3].datawords := 223; ecls[15][3].nrsb := 2;
  ecls[15][3].rsb[0] := rsbs[90]; ecls[15][3].rsb[1] := rsbs[91];
  // version 16
  ecls[16][0].datawords := 589; ecls[16][0].nrsb := 2;
  ecls[16][0].rsb[0] := rsbs[92]; ecls[16][0].rsb[1] := rsbs[93];
  ecls[16][1].datawords := 453; ecls[16][1].nrsb := 2;
  ecls[16][1].rsb[0] := rsbs[94]; ecls[16][1].rsb[1] := rsbs[95];
  ecls[16][2].datawords := 325; ecls[16][2].nrsb := 2;
  ecls[16][2].rsb[0] := rsbs[96]; ecls[16][2].rsb[1] := rsbs[97];
  ecls[16][3].datawords := 253; ecls[16][3].nrsb := 2;
  ecls[16][3].rsb[0] := rsbs[98]; ecls[16][3].rsb[1] := rsbs[99];
  // version 17
  ecls[17][0].datawords := 647; ecls[17][0].nrsb := 2;
  ecls[17][0].rsb[0] := rsbs[100]; ecls[17][0].rsb[1] := rsbs[101];
  ecls[17][1].datawords := 507; ecls[17][1].nrsb := 2;
  ecls[17][1].rsb[0] := rsbs[102]; ecls[17][1].rsb[1] := rsbs[103];
  ecls[17][2].datawords := 367; ecls[17][2].nrsb := 2;
  ecls[17][2].rsb[0] := rsbs[104]; ecls[17][2].rsb[1] := rsbs[105];
  ecls[17][3].datawords := 283; ecls[17][3].nrsb := 2;
  ecls[17][3].rsb[0] := rsbs[106]; ecls[17][3].rsb[1] := rsbs[107];
  // version 18
  ecls[18][0].datawords := 721; ecls[18][0].nrsb := 2;
  ecls[18][0].rsb[0] := rsbs[108]; ecls[18][0].rsb[1] := rsbs[109];
  ecls[18][1].datawords := 563; ecls[18][1].nrsb := 2;
  ecls[18][1].rsb[0] := rsbs[110]; ecls[18][1].rsb[1] := rsbs[111];
  ecls[18][2].datawords := 397; ecls[18][2].nrsb := 2;
  ecls[18][2].rsb[0] := rsbs[112]; ecls[18][2].rsb[1] := rsbs[113];
  ecls[18][3].datawords := 313; ecls[18][3].nrsb := 2;
  ecls[18][3].rsb[0] := rsbs[114]; ecls[18][3].rsb[1] := rsbs[115];
  // version 19
  ecls[19][0].datawords := 795; ecls[19][0].nrsb := 2;
  ecls[19][0].rsb[0] := rsbs[116]; ecls[19][0].rsb[1] := rsbs[117];
  ecls[19][1].datawords := 627; ecls[19][1].nrsb := 2;
  ecls[19][1].rsb[0] := rsbs[118]; ecls[19][1].rsb[1] := rsbs[119];
  ecls[19][2].datawords := 445; ecls[19][2].nrsb := 2;
  ecls[19][2].rsb[0] := rsbs[120]; ecls[19][2].rsb[1] := rsbs[121];
  ecls[19][3].datawords := 341; ecls[19][3].nrsb := 2;
  ecls[19][3].rsb[0] := rsbs[122]; ecls[19][3].rsb[1] := rsbs[123];
  // version 20
  ecls[20][0].datawords := 861; ecls[20][0].nrsb := 2;
  ecls[20][0].rsb[0] := rsbs[124]; ecls[20][0].rsb[1] := rsbs[125];
  ecls[20][1].datawords := 669; ecls[20][1].nrsb := 2;
  ecls[20][1].rsb[0] := rsbs[126]; ecls[20][1].rsb[1] := rsbs[127];
  ecls[20][2].datawords := 485; ecls[20][2].nrsb := 2;
  ecls[20][2].rsb[0] := rsbs[128]; ecls[20][2].rsb[1] := rsbs[129];
  ecls[20][3].datawords := 385; ecls[20][3].nrsb := 2;
  ecls[20][3].rsb[0] := rsbs[130]; ecls[20][3].rsb[1] := rsbs[131];
  // version 21
  ecls[21][0].datawords := 932; ecls[21][0].nrsb := 2;
  ecls[21][0].rsb[0] := rsbs[132]; ecls[21][0].rsb[1] := rsbs[133];
  ecls[21][1].datawords := 714; ecls[21][1].nrsb := 1;
  ecls[21][1].rsb[0] := rsbs[134];
  ecls[21][2].datawords := 512; ecls[21][2].nrsb := 2;
  ecls[21][2].rsb[0] := rsbs[135]; ecls[21][2].rsb[1] := rsbs[136];
  ecls[21][3].datawords := 406; ecls[21][3].nrsb := 2;
  ecls[21][3].rsb[0] := rsbs[137]; ecls[21][3].rsb[1] := rsbs[138];
  // version 22
  ecls[22][0].datawords := 1006; ecls[22][0].nrsb := 2;
  ecls[22][0].rsb[0] := rsbs[139]; ecls[22][0].rsb[1] := rsbs[140];
  ecls[22][1].datawords := 782; ecls[22][1].nrsb := 1;
  ecls[22][1].rsb[0] := rsbs[141];
  ecls[22][2].datawords := 568; ecls[22][2].nrsb := 2;
  ecls[22][2].rsb[0] := rsbs[142]; ecls[22][2].rsb[1] := rsbs[143];
  ecls[22][3].datawords := 442; ecls[22][3].nrsb := 1;
  ecls[22][3].rsb[0] := rsbs[144];
  // version 23
  ecls[23][0].datawords := 1094; ecls[23][0].nrsb := 2;
  ecls[23][0].rsb[0] := rsbs[145]; ecls[23][0].rsb[1] := rsbs[146];
  ecls[23][1].datawords := 860; ecls[23][1].nrsb := 2;
  ecls[23][1].rsb[0] := rsbs[147]; ecls[23][1].rsb[1] := rsbs[148];
  ecls[23][2].datawords := 614; ecls[23][2].nrsb := 2;
  ecls[23][2].rsb[0] := rsbs[149]; ecls[23][2].rsb[1] := rsbs[150];
  ecls[23][3].datawords := 464; ecls[23][3].nrsb := 2;
  ecls[23][3].rsb[0] := rsbs[151]; ecls[23][3].rsb[1] := rsbs[152];
  // version 24
  ecls[24][0].datawords := 1174; ecls[24][0].nrsb := 2;
  ecls[24][0].rsb[0] := rsbs[153]; ecls[24][0].rsb[1] := rsbs[154];
  ecls[24][1].datawords := 914; ecls[24][1].nrsb := 2;
  ecls[24][1].rsb[0] := rsbs[155]; ecls[24][1].rsb[1] := rsbs[156];
  ecls[24][2].datawords := 664; ecls[24][2].nrsb := 2;
  ecls[24][2].rsb[0] := rsbs[157]; ecls[24][2].rsb[1] := rsbs[158];
  ecls[24][3].datawords := 514; ecls[24][3].nrsb := 2;
  ecls[24][3].rsb[0] := rsbs[159]; ecls[24][3].rsb[1] := rsbs[160];
  // version 25
  ecls[25][0].datawords := 1276; ecls[25][0].nrsb := 2;
  ecls[25][0].rsb[0] := rsbs[161]; ecls[25][0].rsb[1] := rsbs[162];
  ecls[25][1].datawords := 1000; ecls[25][1].nrsb := 2;
  ecls[25][1].rsb[0] := rsbs[163]; ecls[25][1].rsb[1] := rsbs[164];
  ecls[25][2].datawords := 718; ecls[25][2].nrsb := 2;
  ecls[25][2].rsb[0] := rsbs[165]; ecls[25][2].rsb[1] := rsbs[166];
  ecls[25][3].datawords := 538; ecls[25][3].nrsb := 2;
  ecls[25][3].rsb[0] := rsbs[167]; ecls[25][3].rsb[1] := rsbs[168];
  // version 26
  ecls[26][0].datawords := 1370; ecls[26][0].nrsb := 2;
  ecls[26][0].rsb[0] := rsbs[169]; ecls[26][0].rsb[1] := rsbs[170];
  ecls[26][1].datawords := 1062; ecls[26][1].nrsb := 2;
  ecls[26][1].rsb[0] := rsbs[171]; ecls[26][1].rsb[1] := rsbs[172];
  ecls[26][2].datawords := 754; ecls[26][2].nrsb := 2;
  ecls[26][2].rsb[0] := rsbs[173]; ecls[26][2].rsb[1] := rsbs[174];
  ecls[26][3].datawords := 596; ecls[26][3].nrsb := 2;
  ecls[26][3].rsb[0] := rsbs[175]; ecls[26][3].rsb[1] := rsbs[176];
  // version 27
  ecls[27][0].datawords := 1468; ecls[27][0].nrsb := 2;
  ecls[27][0].rsb[0] := rsbs[177]; ecls[27][0].rsb[1] := rsbs[178];
  ecls[27][1].datawords := 1128; ecls[27][1].nrsb := 2;
  ecls[27][1].rsb[0] := rsbs[179]; ecls[27][1].rsb[1] := rsbs[180];
  ecls[27][2].datawords := 808; ecls[27][2].nrsb := 2;
  ecls[27][2].rsb[0] := rsbs[181]; ecls[27][2].rsb[1] := rsbs[182];
  ecls[27][3].datawords := 628; ecls[27][3].nrsb := 2;
  ecls[27][3].rsb[0] := rsbs[183]; ecls[27][3].rsb[1] := rsbs[184];
  // version 28
  ecls[28][0].datawords := 1531; ecls[28][0].nrsb := 2;
  ecls[28][0].rsb[0] := rsbs[185]; ecls[28][0].rsb[1] := rsbs[186];
  ecls[28][1].datawords := 1193; ecls[28][1].nrsb := 2;
  ecls[28][1].rsb[0] := rsbs[187]; ecls[28][1].rsb[1] := rsbs[188];
  ecls[28][2].datawords := 871; ecls[28][2].nrsb := 2;
  ecls[28][2].rsb[0] := rsbs[189]; ecls[28][2].rsb[1] := rsbs[190];
  ecls[28][3].datawords := 661; ecls[28][3].nrsb := 2;
  ecls[28][3].rsb[0] := rsbs[191]; ecls[28][3].rsb[1] := rsbs[192];
  // version 29
  ecls[29][0].datawords := 1631; ecls[29][0].nrsb := 2;
  ecls[29][0].rsb[0] := rsbs[193]; ecls[29][0].rsb[1] := rsbs[194];
  ecls[29][1].datawords := 1267; ecls[29][1].nrsb := 2;
  ecls[29][1].rsb[0] := rsbs[195]; ecls[29][1].rsb[1] := rsbs[196];
  ecls[29][2].datawords := 911; ecls[29][2].nrsb := 2;
  ecls[29][2].rsb[0] := rsbs[197]; ecls[29][2].rsb[1] := rsbs[198];
  ecls[29][3].datawords := 701; ecls[29][3].nrsb := 2;
  ecls[29][3].rsb[0] := rsbs[199]; ecls[29][3].rsb[1] := rsbs[200];
  // version 30
  ecls[30][0].datawords := 1735; ecls[30][0].nrsb := 2;
  ecls[30][0].rsb[0] := rsbs[201]; ecls[30][0].rsb[1] := rsbs[202];
  ecls[30][1].datawords := 1373; ecls[30][1].nrsb := 2;
  ecls[30][1].rsb[0] := rsbs[203]; ecls[30][1].rsb[1] := rsbs[204];
  ecls[30][2].datawords := 985; ecls[30][2].nrsb := 2;
  ecls[30][2].rsb[0] := rsbs[205]; ecls[30][2].rsb[1] := rsbs[206];
  ecls[30][3].datawords := 745; ecls[30][3].nrsb := 2;
  ecls[30][3].rsb[0] := rsbs[207]; ecls[30][3].rsb[1] := rsbs[208];
  // version 31
  ecls[31][0].datawords := 1843; ecls[31][0].nrsb := 2;
  ecls[31][0].rsb[0] := rsbs[209]; ecls[31][0].rsb[1] := rsbs[210];
  ecls[31][1].datawords := 1455; ecls[31][1].nrsb := 2;
  ecls[31][1].rsb[0] := rsbs[211]; ecls[31][1].rsb[1] := rsbs[212];
  ecls[31][2].datawords := 1033; ecls[31][2].nrsb := 2;
  ecls[31][2].rsb[0] := rsbs[213]; ecls[31][2].rsb[1] := rsbs[214];
  ecls[31][3].datawords := 793; ecls[31][3].nrsb := 2;
  ecls[31][3].rsb[0] := rsbs[215]; ecls[31][3].rsb[1] := rsbs[216];
  // version 32
  ecls[32][0].datawords := 1955; ecls[32][0].nrsb := 1;
  ecls[32][0].rsb[0] := rsbs[217];
  ecls[32][1].datawords := 1541; ecls[32][1].nrsb := 2;
  ecls[32][1].rsb[0] := rsbs[218]; ecls[32][1].rsb[1] := rsbs[219];
  ecls[32][2].datawords := 1115; ecls[32][2].nrsb := 2;
  ecls[32][2].rsb[0] := rsbs[220]; ecls[32][2].rsb[1] := rsbs[221];
  ecls[32][3].datawords := 845; ecls[32][3].nrsb := 2;
  ecls[32][3].rsb[0] := rsbs[222]; ecls[32][3].rsb[1] := rsbs[223];
  // version 33
  ecls[33][0].datawords := 2071; ecls[33][0].nrsb := 2;
  ecls[33][0].rsb[0] := rsbs[224]; ecls[33][0].rsb[1] := rsbs[225];
  ecls[33][1].datawords := 1631; ecls[33][1].nrsb := 2;
  ecls[33][1].rsb[0] := rsbs[226]; ecls[33][1].rsb[1] := rsbs[227];
  ecls[33][2].datawords := 1171; ecls[33][2].nrsb := 2;
  ecls[33][2].rsb[0] := rsbs[228]; ecls[33][2].rsb[1] := rsbs[229];
  ecls[33][3].datawords := 901; ecls[33][3].nrsb := 2;
  ecls[33][3].rsb[0] := rsbs[230]; ecls[33][3].rsb[1] := rsbs[231];
  // version 34
  ecls[34][0].datawords := 2191; ecls[34][0].nrsb := 2;
  ecls[34][0].rsb[0] := rsbs[232]; ecls[34][0].rsb[1] := rsbs[233];
  ecls[34][1].datawords := 1725; ecls[34][1].nrsb := 2;
  ecls[34][1].rsb[0] := rsbs[234]; ecls[34][1].rsb[1] := rsbs[235];
  ecls[34][2].datawords := 1231; ecls[34][2].nrsb := 2;
  ecls[34][2].rsb[0] := rsbs[236]; ecls[34][2].rsb[1] := rsbs[237];
  ecls[34][3].datawords := 961; ecls[34][3].nrsb := 2;
  ecls[34][3].rsb[0] := rsbs[238]; ecls[34][3].rsb[1] := rsbs[239];
  // version 35
  ecls[35][0].datawords := 2306; ecls[35][0].nrsb := 2;
  ecls[35][0].rsb[0] := rsbs[240]; ecls[35][0].rsb[1] := rsbs[241];
  ecls[35][1].datawords := 1812; ecls[35][1].nrsb := 2;
  ecls[35][1].rsb[0] := rsbs[242]; ecls[35][1].rsb[1] := rsbs[243];
  ecls[35][2].datawords := 1286; ecls[35][2].nrsb := 2;
  ecls[35][2].rsb[0] := rsbs[244]; ecls[35][2].rsb[1] := rsbs[245];
  ecls[35][3].datawords := 986; ecls[35][3].nrsb := 2;
  ecls[35][3].rsb[0] := rsbs[246]; ecls[35][3].rsb[1] := rsbs[247];
  // version 36
  ecls[36][0].datawords := 2434; ecls[36][0].nrsb := 2;
  ecls[36][0].rsb[0] := rsbs[248]; ecls[36][0].rsb[1] := rsbs[249];
  ecls[36][1].datawords := 1914; ecls[36][1].nrsb := 2;
  ecls[36][1].rsb[0] := rsbs[250]; ecls[36][1].rsb[1] := rsbs[251];
  ecls[36][2].datawords := 1354; ecls[36][2].nrsb := 2;
  ecls[36][2].rsb[0] := rsbs[252]; ecls[36][2].rsb[1] := rsbs[253];
  ecls[36][3].datawords := 1054; ecls[36][3].nrsb := 2;
  ecls[36][3].rsb[0] := rsbs[254]; ecls[36][3].rsb[1] := rsbs[255];
  // version 37
  ecls[37][0].datawords := 2566; ecls[37][0].nrsb := 2;
  ecls[37][0].rsb[0] := rsbs[256]; ecls[37][0].rsb[1] := rsbs[257];
  ecls[37][1].datawords := 1992; ecls[37][1].nrsb := 2;
  ecls[37][1].rsb[0] := rsbs[258]; ecls[37][1].rsb[1] := rsbs[259];
  ecls[37][2].datawords := 1426; ecls[37][2].nrsb := 2;
  ecls[37][2].rsb[0] := rsbs[260]; ecls[37][2].rsb[1] := rsbs[261];
  ecls[37][3].datawords := 1096; ecls[37][3].nrsb := 2;
  ecls[37][3].rsb[0] := rsbs[262]; ecls[37][3].rsb[1] := rsbs[263];
  // version 38
  ecls[38][0].datawords := 2702; ecls[38][0].nrsb := 2;
  ecls[38][0].rsb[0] := rsbs[264]; ecls[38][0].rsb[1] := rsbs[265];
  ecls[38][1].datawords := 2102; ecls[38][1].nrsb := 2;
  ecls[38][1].rsb[0] := rsbs[266]; ecls[38][1].rsb[1] := rsbs[267];
  ecls[38][2].datawords := 1502; ecls[38][2].nrsb := 2;
  ecls[38][2].rsb[0] := rsbs[268]; ecls[38][2].rsb[1] := rsbs[269];
  ecls[38][3].datawords := 1142; ecls[38][3].nrsb := 2;
  ecls[38][3].rsb[0] := rsbs[270]; ecls[38][3].rsb[1] := rsbs[271];
  // version 39
  ecls[39][0].datawords := 2812; ecls[39][0].nrsb := 2;
  ecls[39][0].rsb[0] := rsbs[272]; ecls[39][0].rsb[1] := rsbs[273];
  ecls[39][1].datawords := 2216; ecls[39][1].nrsb := 2;
  ecls[39][1].rsb[0] := rsbs[274]; ecls[39][1].rsb[1] := rsbs[275];
  ecls[39][2].datawords := 1582; ecls[39][2].nrsb := 2;
  ecls[39][2].rsb[0] := rsbs[276]; ecls[39][2].rsb[1] := rsbs[277];
  ecls[39][3].datawords := 1222; ecls[39][3].nrsb := 2;
  ecls[39][3].rsb[0] := rsbs[278]; ecls[39][3].rsb[1] := rsbs[279];
  // version 40
  ecls[40][0].datawords := 2956; ecls[40][0].nrsb := 2;
  ecls[40][0].rsb[0] := rsbs[280]; ecls[40][0].rsb[1] := rsbs[281];
  ecls[40][1].datawords := 2334; ecls[40][1].nrsb := 2;
  ecls[40][1].rsb[0] := rsbs[282]; ecls[40][1].rsb[1] := rsbs[283];
  ecls[40][2].datawords := 1666; ecls[40][2].nrsb := 2;
  ecls[40][2].rsb[0] := rsbs[284]; ecls[40][2].rsb[1] := rsbs[285];
  ecls[40][3].datawords := 1276; ecls[40][3].nrsb := 2;
  ecls[40][3].rsb[0] := rsbs[286]; ecls[40][3].rsb[1] := rsbs[287];

  { vertable: array[0..QR_VER_MAX] of QR_VERTABLE 型番データ表の初期化 }
  ZeroMemory(@vertable, SizeOf(vertable));
  k := 0;
  for i := 1 to QR_VER_MAX do
  begin
    vertable[i].version := i;
    if i in [10, 27] then
      Inc(k);
    for j := 0 to (QR_EM_MAX  - 1) do
      vertable[i].nlen[j] := nlens[k][j];
    for j := 0 to (QR_ECL_MAX  - 1) do
      vertable[i].ecl[j] := ecls[i][j];
    for j := 0 to (QR_APL_MAX  - 1) do
      vertable[i].aploc[j] := aplocs[i][j];
  end;
  // version 1
  vertable[1].dimension := 21;
  vertable[1].totalwords := 26;
  vertable[1].remainedbits := 0;
  vertable[1].aplnum := 0;
  // version 2
  vertable[2].dimension := 25;
  vertable[2].totalwords := 44;
  vertable[2].remainedbits := 7;
  vertable[2].aplnum := 2;
  // version 3
  vertable[3].dimension := 29;
  vertable[3].totalwords := 70;
  vertable[3].remainedbits := 7;
  vertable[3].aplnum := 2;
  // version 4
  vertable[4].dimension := 33;
  vertable[4].totalwords := 100;
  vertable[4].remainedbits := 7;
  vertable[4].aplnum := 2;
  // version 5
  vertable[5].dimension := 37;
  vertable[5].totalwords := 134;
  vertable[5].remainedbits := 7;
  vertable[5].aplnum := 2;
  // version 6
  vertable[6].dimension := 41;
  vertable[6].totalwords := 172;
  vertable[6].remainedbits := 7;
  vertable[6].aplnum := 2;
  // version 7
  vertable[7].dimension := 45;
  vertable[7].totalwords := 196;
  vertable[7].remainedbits := 0;
  vertable[7].aplnum := 3;
  // version 8
  vertable[8].dimension := 49;
  vertable[8].totalwords := 242;
  vertable[8].remainedbits := 0;
  vertable[8].aplnum := 3;
  // version 9
  vertable[9].dimension := 53;
  vertable[9].totalwords := 292;
  vertable[9].remainedbits := 0;
  vertable[9].aplnum := 3;
  // version 10
  vertable[10].dimension := 57;
  vertable[10].totalwords := 346;
  vertable[10].remainedbits := 0;
  vertable[10].aplnum := 3;
  // version 11
  vertable[11].dimension := 61;
  vertable[11].totalwords := 404;
  vertable[11].remainedbits := 0;
  vertable[11].aplnum := 3;
  // version 12
  vertable[12].dimension := 65;
  vertable[12].totalwords := 466;
  vertable[12].remainedbits := 0;
  vertable[12].aplnum := 3;
  // version 13
  vertable[13].dimension := 69;
  vertable[13].totalwords := 532;
  vertable[13].remainedbits := 0;
  vertable[13].aplnum := 3;
  // version 14
  vertable[14].dimension := 73;
  vertable[14].totalwords := 581;
  vertable[14].remainedbits := 3;
  vertable[14].aplnum := 4;
  // version 15
  vertable[15].dimension := 77;
  vertable[15].totalwords := 655;
  vertable[15].remainedbits := 3;
  vertable[15].aplnum := 4;
  // version 16
  vertable[16].dimension := 81;
  vertable[16].totalwords := 733;
  vertable[16].remainedbits := 3;
  vertable[16].aplnum := 4;
  // version 17
  vertable[17].dimension := 85;
  vertable[17].totalwords := 815;
  vertable[17].remainedbits := 3;
  vertable[17].aplnum := 4;
  // version 18
  vertable[18].dimension := 89;
  vertable[18].totalwords := 901;
  vertable[18].remainedbits := 3;
  vertable[18].aplnum := 4;
  // version 19
  vertable[19].dimension := 93;
  vertable[19].totalwords := 991;
  vertable[19].remainedbits := 3;
  vertable[19].aplnum := 4;
  // version 20
  vertable[20].dimension := 97;
  vertable[20].totalwords := 1085;
  vertable[20].remainedbits := 3;
  vertable[20].aplnum := 4;
  // version 21
  vertable[21].dimension := 101;
  vertable[21].totalwords := 1156;
  vertable[21].remainedbits := 4;
  vertable[21].aplnum := 5;
  // version 22
  vertable[22].dimension := 105;
  vertable[22].totalwords := 1258;
  vertable[22].remainedbits := 4;
  vertable[22].aplnum := 5;
  // version 23
  vertable[23].dimension := 109;
  vertable[23].totalwords := 1364;
  vertable[23].remainedbits := 4;
  vertable[23].aplnum := 5;
  // version 24
  vertable[24].dimension := 113;
  vertable[24].totalwords := 1474;
  vertable[24].remainedbits := 4;
  vertable[24].aplnum := 5;
  // version 25
  vertable[25].dimension := 117;
  vertable[25].totalwords := 1588;
  vertable[25].remainedbits := 4;
  vertable[25].aplnum := 5;
  // version 26
  vertable[26].dimension := 121;
  vertable[26].totalwords := 1706;
  vertable[26].remainedbits := 4;
  vertable[26].aplnum := 5;
  // version 27
  vertable[27].dimension := 125;
  vertable[27].totalwords := 1828;
  vertable[27].remainedbits := 4;
  vertable[27].aplnum := 5;
  // version 28
  vertable[28].dimension := 129;
  vertable[28].totalwords := 1921;
  vertable[28].remainedbits := 3;
  vertable[28].aplnum := 6;
  // version 29
  vertable[29].dimension := 133;
  vertable[29].totalwords := 2051;
  vertable[29].remainedbits := 3;
  vertable[29].aplnum := 6;
  // version 30
  vertable[30].dimension := 137;
  vertable[30].totalwords := 2185;
  vertable[30].remainedbits := 3;
  vertable[30].aplnum := 6;
  // version 31
  vertable[31].dimension := 141;
  vertable[31].totalwords := 2323;
  vertable[31].remainedbits := 3;
  vertable[31].aplnum := 6;
  // version 32
  vertable[32].dimension := 145;
  vertable[32].totalwords := 2465;
  vertable[32].remainedbits := 3;
  vertable[32].aplnum := 6;
  // version 33
  vertable[33].dimension := 149;
  vertable[33].totalwords := 2611;
  vertable[33].remainedbits := 3;
  vertable[33].aplnum := 6;
  // version 34
  vertable[34].dimension := 153;
  vertable[34].totalwords := 2761;
  vertable[34].remainedbits := 3;
  vertable[34].aplnum := 6;
  // version 35
  vertable[35].dimension := 157;
  vertable[35].totalwords := 2876;
  vertable[35].remainedbits := 0;
  vertable[35].aplnum := 7;
  // version 36
  vertable[36].dimension := 161;
  vertable[36].totalwords := 3034;
  vertable[36].remainedbits := 0;
  vertable[36].aplnum := 7;
  // version 37
  vertable[37].dimension := 165;
  vertable[37].totalwords := 3196;
  vertable[37].remainedbits := 0;
  vertable[37].aplnum := 7;
  // version 38
  vertable[38].dimension := 169;
  vertable[38].totalwords := 3362;
  vertable[38].remainedbits := 0;
  vertable[38].aplnum := 7;
  // version 39
  vertable[39].dimension := 173;
  vertable[39].totalwords := 3532;
  vertable[39].remainedbits := 0;
  vertable[39].aplnum := 7;
  // version 40
  vertable[40].dimension := 177;
  vertable[40].totalwords := 3706;
  vertable[40].remainedbits := 0;
  vertable[40].aplnum := 7;
end;

function TQRCode.isBlack(i, j: Integer): Boolean;
begin
  Result := ((symbol[i][j] and QR_MM_BLACK) <> 0);
end;

function TQRCode.isData(i, j: Integer): Boolean;
begin
  Result := ((symbol[i][j] and QR_MM_DATA) <> 0);
end;

function TQRCode.isFunc(i, j: Integer): Boolean;
begin
  Result := ((symbol[i][j] and QR_MM_FUNC) <> 0);
end;

procedure TQRCode.PaintSymbol;   // イベントメソッド
begin
  if Assigned(FOnPaintSymbol) then
    FOnPaintSymbol(Self);        // イベントハンドラの呼び出し
end;

procedure TQRCode.PaintedSymbol; // イベントメソッド
begin
  if Assigned(FOnPaintedSymbol) then
    FOnPaintedSymbol(Self);      // イベントハンドラの呼び出し
end;

procedure TQRCode.PaintSymbolCode;
begin
  if FSymbolEnabled = False then // 一時的にシンボル表示を停止している状態
    Exit;

  PaintSymbol;                   // OnPaintSymbol イベントをここで発生

  if Picture.Bitmap.Empty = True then
  begin
    Picture.Bitmap.Width := Width;
    Picture.Bitmap.Height := Height;
  end;

  if FSymbolPicture = psymBMP then
    PaintSymbolCodeB  // Picture.Bitmap への描画を行なう場合
  else
    PaintSymbolCodeM; // Picture.Metafile への描画を行なう場合

  PaintedSymbol;      // OnPaintedSymbol イベントをここで発生

  if (FSymbolDisped = False) and (FClearOption = True) then
  begin
    if FSymbolDebug = False then
      Clear;          // 画面をクリアーする。
  end;
end;

procedure TQRCode.PaintSymbolCodeB;
var
  Done: Integer;
  lx, ly, rx, ry: Integer;
  x, y: Integer;
  inBlack: Boolean;
  SX, SY: Integer; // シンボルの描画開始位置
  dim: Integer;    // 一辺のモジュール数
  CmtUpWidth, CmtUpHeight: Integer;     // 上部のコメント部分の大きさ
  CmtDownWidth, CmtDownHeight: Integer; // 下部のコメント部分の大きさ
  PositionUp, PositionDown: Integer;    // 各コメントの表示開始位置
  UpLimit, DownLimit: Integer;          // 各コメントの表示開始の限界位置
  ww, hh: Integer;
  asz, srh: Boolean;
  OrgFont: TFont;
begin
  FSymbolDisped := False;

  if FEmode = -1 then
    Done := qrEncodeDataWordA  // 自動符号化モード
  else
    Done := qrEncodeDataWordM; // 符号化モードが指定されている

  if Done = -1 then // 表示に失敗した
    Exit;

  asz := AutoSize;
  srh := Stretch;
  AutoSize := False;
  Stretch := False;

  qrComputeECWord;       // 誤り訂正コード語を計算する
  qrMakeCodeWord;        // 最終生成コード語を求める
  qrFillFunctionPattern; // シンボルに機能パターンを配置する
  qrFillCodeWord;        // シンボルにコード語を配置する
  qrSelectMaskPattern;   // シンボルにマスク処理を行う
  qrFillFormatInfo;      // シンボルに型情報と形式情報を配置する

  { デバッグモードの場合 }
  if SymbolDebug = True then
  begin
    FSymbolDisped := True;
    AutoSize := asz;
    Stretch := srh;
    Exit;
  end;

  { 各コメント部分の大きさを求める。}
  OrgFont := Canvas.Font;
  Canvas.Font := FComFont;
  if FCommentUp <> '' then
  begin
    CmtUpWidth := Canvas.TextWidth(FCommentUp);
    CmtUpHeight := Canvas.TextHeight(FCommentUp);
  end
  else
  begin
    CmtUpWidth := 0;
    CmtUpHeight := 0;
  end;

  if FCommentDown <> '' then
  begin
    CmtDownWidth := Canvas.TextWidth(FCommentDown);
    CmtDownHeight := Canvas.TextHeight(FCommentDown);
  end
  else
  begin
    CmtDownWidth := 0;
    CmtDownHeight := 0;
  end;
  Canvas.Font := OrgFont;

  ww := FSymbolLeft + FSymbolSpaceLeft + SymbolWidth + FSymbolSpaceRight;
  hh := FSymbolTop + FSymbolSpaceUp + SymbolHeight + FSymbolSpaceDown;

  { コントロールのサイズをシンボルのサイズに合わせる場合 }
  if FMatch = True then
  begin
    Width := ww;
    Height := hh;
    Picture.Bitmap.Width := Width;
    Picture.Bitmap.Height := Height;
  end;

  { Canvas の Pen を設定する。}
  Canvas.Pen.Color := FSymbolColor;
  Canvas.Pen.Style := psSolid;

  { シンボルの背景を描く。}
  if FTransparent = False then
  begin
    Canvas.Brush.Color := FBackColor;
    Canvas.Brush.Style := bsSolid;
    if FMatch = True then
      Canvas.FillRect(Rect(0, 0, ww, hh))
    else
      Canvas.FillRect(Rect(FSymbolLeft, FSymbolTop, ww, hh));
  end;

  { Canvas の Brush を設定する。}
  Canvas.Brush.Color := FSymbolColor;
  Canvas.Brush.Style := bsSolid;

  { シンボルを描く。}
  // シンボルの描画開始位置(X座標)
  SX := FSymbolLeft + FSymbolSpaceLeft + QR_DIM_SEP * FPxmag;
  // シンボルの描画開始位置(Y座標)
  SY := FSymbolTop + FSymbolSpaceUp + QR_DIM_SEP * FPxmag;
  dim := vertable[FVersion].dimension; // 一辺のモジュール数

  for y := 0 to dim - 1 do
  begin
    lx := 0;
    ly := y * FPxmag;
    ry := ly + FPxmag;
    inBlack := False;
    for x := 0 to dim - 1 do
    begin
      if (inBlack = False) and (isBlack(y, x) = True) then
      begin
        lx := x * FPxmag;
        inBlack := True;
      end
      else if (inBlack = True) and (isBlack(y, x) = False) then
      begin
        rx := x * FPxmag;
        Canvas.FillRect(Rect(SX + lx, SY + ly, SX + rx, SY + ry));
        inBlack := False;
      end;
    end;
    if inBlack = True then
    begin
      rx := dim * FPxmag;
      Canvas.FillRect(Rect(SX + lx, SY + ly, SX + rx, SY + ry));
    end;
  end;

  { シンボルの上下にコメントを描く場合の処理 }
  Canvas.Brush.Color := FBackColor;
  Canvas.Brush.Style := bsSolid;
  OrgFont := Canvas.Font;
  Canvas.Font := FComFont;
  if FCommentUp <> '' then
  begin
    case FCommentUpLoc of
      locsLeft:
        PositionUp := 0;
      locsCenter:
        PositionUp := (FSymbolSpaceLeft + SymbolWidth + FSymbolSpaceRight
         - CmtUpWidth) div 2;
      locsRight:
        PositionUp := FSymbolSpaceLeft + SymbolWidth + FSymbolSpaceRight
         - CmtUpWidth;
    else
      PositionUp := 0;
    end;
    if PositionUp < 0 then
      PositionUp := 0;
    UpLimit := FSymbolTop + FSymbolSpaceUp - CmtUpHeight;
    y := FSymbolTop;
    if y > UpLimit then
      y := UpLimit;
    Canvas.TextOut(FSymbolLeft + PositionUp, y, FCommentUp);
  end;

  if FCommentDown <> '' then
  begin
    case FCommentDownLoc of
      locsLeft:
        PositionDown := 0;
      locsCenter:
        PositionDown := (FSymbolSpaceLeft + SymbolWidth + FSymbolSpaceRight
         - CmtDownWidth) div 2;
      locsRight:
        PositionDown := FSymbolSpaceLeft + SymbolWidth + FSymbolSpaceRight
         - CmtDownWidth;
    else
      PositionDown := 0;
    end;
    if PositionDown < 0 then
      PositionDown := 0;
    DownLimit := FSymbolTop + FSymbolSpaceUp + SymbolHeight;
    y := FSymbolTop + FSymbolSpaceUp + SymbolHeight + FSymbolSpaceDown
     - CmtDownHeight;
    if y < DownLimit then
      y := DownLimit;
    Canvas.TextOut(FSymbolLeft + PositionDown, y, FCommentDown);
  end;
  Canvas.Font := OrgFont;

  AutoSize := asz;
  Stretch := srh;
  FSymbolDisped := True;
end;

procedure TQRCode.PaintSymbolCodeM;
var
  Done: Integer;
  lx, ly, rx, ry: Integer;
  x, y: Integer;
  inBlack: Boolean;
  SX, SY: Integer; // シンボルの描画開始位置
  dim: Integer;    // 一辺のモジュール数
  CmtUpWidth, CmtUpHeight: Integer;     // 上部のコメント部分の大きさ
  CmtDownWidth, CmtDownHeight: Integer; // 下部のコメント部分の大きさ
  PositionUp, PositionDown: Integer;    // 各コメントの表示開始位置
  UpLimit, DownLimit: Integer;          // 各コメントの表示開始の限界位置
  asz, srh: Boolean;
  OrgFont: TFont;
begin
  FSymbolDisped := False;

  if FEmode = -1 then
    Done := qrEncodeDataWordA  // 自動符号化モード
  else
    Done := qrEncodeDataWordM; // 符号化モードが指定されている

  if Done = -1 then // 表示に失敗した
    Exit;

  asz := AutoSize;
  srh := Stretch;
  AutoSize := False;
  Stretch := False;

  qrComputeECWord;       // 誤り訂正コード語を計算する
  qrMakeCodeWord;        // 最終生成コード語を求める
  qrFillFunctionPattern; // シンボルに機能パターンを配置する
  qrFillCodeWord;        // シンボルにコード語を配置する
  qrSelectMaskPattern;   // シンボルにマスク処理を行う
  qrFillFormatInfo;      // シンボルに型情報と形式情報を配置する

  { デバッグモードの場合 }
  if SymbolDebug = True then
  begin
    FSymbolDisped := True;
    AutoSize := asz;
    Stretch := srh;
    Exit;
  end;

  { 各コメント部分の大きさを求める。}
  OrgFont := Canvas.Font;
  Canvas.Font := FComFont;
  if FCommentUp <> '' then
  begin
    CmtUpWidth := Canvas.TextWidth(FCommentUp);
    CmtUpHeight := Canvas.TextHeight(FCommentUp);
  end
  else
  begin
    CmtUpWidth := 0;
    CmtUpHeight := 0;
  end;

  if FCommentDown <> '' then
  begin
    CmtDownWidth := Canvas.TextWidth(FCommentDown);
    CmtDownHeight := Canvas.TextHeight(FCommentDown);
  end
  else
  begin
    CmtDownWidth := 0;
    CmtDownHeight := 0;
  end;
  Canvas.Font := OrgFont;

  { コントロールのサイズをバーコードのサイズに合わせる。}
  Width := FSymbolLeft + FSymbolSpaceLeft + SymbolWidth + FSymbolSpaceRight;
  Height := FSymbolTop + FSymbolSpaceUp + SymbolHeight + FSymbolSpaceDown;
  Picture.Metafile.Width := Width;
  Picture.Metafile.Height := Height;

  { メタファイルのキャンバスを用意する。 }
  FMfCanvas := TMetafileCanvas.Create(Picture.Metafile, GetDC(0));

  { FMfCanvas の Pen と Brush を設定する。 }
  FMfCanvas.Pen.Color := FSymbolColor;
  FMfCanvas.Pen.Style := psSolid;
  FMfCanvas.Brush.Color := FBackColor;
  FMfCanvas.Brush.Style := bsSolid;

  { シンボルの背景を描く。 }
  FMfCanvas.FillRect(Rect(0, 0, Width, Height));
  FMfCanvas.Brush.Color := FSymbolColor;
  FMfCanvas.Brush.Style := bsSolid;

  { シンボルを描く。}
  // シンボルの描画開始位置(X座標)
  SX := FSymbolLeft + FSymbolSpaceLeft + QR_DIM_SEP * FPxmag;
  // シンボルの描画開始位置(Y座標)
  SY := FSymbolTop + FSymbolSpaceUp + QR_DIM_SEP * FPxmag;
  dim := vertable[FVersion].dimension;     // 一辺のモジュール数

  for y := 0 to dim - 1 do
  begin
    lx := 0;
    ly := y * FPxmag;
    ry := ly + FPxmag;
    inBlack := False;
    for x := 0 to dim - 1 do
    begin
      if (inBlack = False) and (isBlack(y, x) = True) then
      begin
        lx := x * FPxmag;
        inBlack := True;
      end
      else if (inBlack = True) and (isBlack(y, x) = False) then
      begin
        rx := x * FPxmag;
        FMfCanvas.FillRect(Rect(SX + lx, SY + ly, SX + rx, SY + ry));
        inBlack := False;
      end;
    end;
    if inBlack = True then
    begin
      rx := dim * FPxmag;
      FMfCanvas.FillRect(Rect(SX + lx, SY + ly, SX + rx, SY + ry));
    end;
  end;

  { シンボルの上下にコメントを描く場合の処理 }
  FMfCanvas.Brush.Color := FBackColor;
  FMfCanvas.Brush.Style := bsSolid;
  FMfCanvas.Font := FComFont;
  if FCommentUp <> '' then
  begin
    case FCommentUpLoc of
      locsLeft:
        PositionUp := 0;
      locsCenter:
        PositionUp := (FSymbolSpaceLeft + SymbolWidth + FSymbolSpaceRight
         - CmtUpWidth) div 2;
      locsRight:
        PositionUp := FSymbolSpaceLeft + SymbolWidth + FSymbolSpaceRight
         - CmtUpWidth;
    else
      PositionUp := 0;
    end;
    if PositionUp < 0 then
      PositionUp := 0;
    UpLimit := FSymbolTop + FSymbolSpaceUp - CmtUpHeight;
    y := FSymbolTop;
    if y > UpLimit then
      y := UpLimit;
    FMfCanvas.TextOut(FSymbolLeft + PositionUp, y, FCommentUp);
  end;

  if FCommentDown <> '' then
  begin
    case FCommentDownLoc of
      locsLeft:
        PositionDown := 0;
      locsCenter:
        PositionDown := (FSymbolSpaceLeft + SymbolWidth + FSymbolSpaceRight
         - CmtDownWidth) div 2;
      locsRight:
        PositionDown := FSymbolSpaceLeft + SymbolWidth + FSymbolSpaceRight
         - CmtDownWidth;
    else
      PositionDown := 0;
    end;
    if PositionDown < 0 then
      PositionDown := 0;
    DownLimit := FSymbolTop + FSymbolSpaceUp + SymbolHeight;
    y := FSymbolTop + FSymbolSpaceUp + SymbolHeight + FSymbolSpaceDown
     - CmtDownHeight;
    if y < DownLimit then
      y := DownLimit;
    FMfCanvas.TextOut(FSymbolLeft + PositionDown, y, FCommentDown);
  end;

  FMfCanvas.Free; // 開放して初めて描画される。

  { なぜか１ピクセル分つぶれる(どこかの線がおかしくなる)ので表示後に }
  { 元にもどす。これは、M&I さんのご指摘により修正した部分です。}
  // 2001/08/05 Modify M&I
  Picture.Metafile.Width := Picture.Metafile.Width + 1;
  Picture.Metafile.Height := Picture.Metafile.Height + 1;

  AutoSize := asz;
  Stretch := srh;
  FSymbolDisped := True;
end;

{ 現在クリップボードにあるテキストデータでバーコードを描画する }
{ メソッドです。先頭の7089バイトまでを有効なデータと見なします。}
procedure TQRCode.PasteFromClipboard;
var
  Str: String;
begin
  if Clipboard.HasFormat(CF_TEXT) = True then
  begin
    Str := Clipboard.AsText;
    Str := Copy(Str, 1, 7089); //  7089バイトまでを有効とする。
    if Str <> FCode then
      Code := Str;
  end;
end;

{ データコード語にビット列を追加する }
procedure TQRCode.qrAddDataBits(n: Integer; w: Longword);
begin
  { 上位ビットから順に処理(ビット単位で処理するので遅い) }
  while n > 0 do
  begin
    Dec(n);
    { ビット追加位置にデータの下位からnビットめをORする }
    dataword[dwpos] := dataword[dwpos] or (((w shr n) and 1) shl dwbit);
    { 次のビット追加位置に進む }
    Dec(dwbit);
    if dwbit < 0 then
    begin
      Inc(dwpos);
      dwbit := 7;
    end;
  end;
end;

{ RSブロックごとに誤り訂正コード語を計算する }
procedure TQRCode.qrComputeECWord;
var
  i, j, k, m: Integer;
  ecwtop, dwtop, nrsb, rsbnum: Integer;
  dwlen, ecwlen: Integer;
  rsb: QR_RSBLOCK;
  e: Integer;
begin
  { データコード語をRSブロックごとに読み出し、}
  { それぞれについて誤り訂正コード語を計算する }
  { RSブロックは長さによってnrsb種類に分かれ、}
  { それぞれの長さについてrsbnum個のブロックがある }
  dwtop := 0;
  ecwtop := 0;
  nrsb := vertable[FVersion].ecl[FEclevel].nrsb;
  for i := 0 to nrsb - 1 do
  begin
    { この長さのRSブロックの個数(rsbnum)と }
    { RSブロック内のデータコード語の長さ(dwlen)、}
    { 誤り訂正コード語の長さ(ecwlen)を求める }
    { また誤り訂正コード語の長さから、使われる }
    { 誤り訂正生成多項式(gftable[ecwlen])が選ばれる }
    rsb := vertable[FVersion].ecl[FEclevel].rsb[i];
    rsbnum := rsb.rsbnum;
    dwlen := rsb.datawords;
    ecwlen := rsb.totalwords - rsb.datawords;
    { それぞれのRSブロックについてデータコード語を }
    { 誤り訂正生成多項式で除算し、結果を誤り訂正 }
    { コード語とする }
    for j := 0 to rsbnum - 1 do
    begin
      { RS符号計算用作業領域をクリアし、}
      { 当該RSブロックのデータコード語を }
      { 多項式係数とみなして作業領域に入れる }
      { (作業領域の大きさはRSブロックの }
      { データコード語と誤り訂正コード語の }
      { いずれか長いほうと同じだけ必要) }
      ZeroMemory(@rswork, SizeOf(rswork));
      CopyMemory(@rswork, @dataword[dwtop], dwlen);
      { 多項式の除算を行う }
      { (各次数についてデータコード語の初項係数から }
      { 誤り訂正生成多項式への乗数を求め、多項式 }
      { どうしの減算により剰余を求めることをくり返す) }
      for k := 0 to dwlen - 1 do
      begin
        if rswork[0] = 0 then
        begin
          { 初項係数がゼロなので、各項係数を }
          { 左にシフトして次の次数に進む }
          for m := 0 to QR_RSD_MAX - 2 do
            rswork[m] := rswork[m + 1];
          rswork[QR_RSD_MAX - 1] := 0;
          Continue;
        end;
        { データコード語の初項係数(整数表現)から }
        { 誤り訂正生成多項式への乗数(べき表現)を求め、}
        { 残りの各項について剰余を求めるために }
        { データコード語の各項係数を左にシフトする }
        e := fac2exp[rswork[0]];
        for m := 0 to QR_RSD_MAX - 2 do
          rswork[m] := rswork[m + 1];
        rswork[QR_RSD_MAX - 1] := 0;
        { 誤り訂正生成多項式の各項係数に上で求めた }
        { 乗数を掛け(べき表現の加算により求める)、}
        { データコード語の各項から引いて(整数表現の }
        { 排他的論理和により求める)、剰余を求める }
        for m := 0 to ecwlen - 1 do
          rswork[m] := rswork[m] xor exp2fac[(gftable[ecwlen][m] + e) mod 255];
      end;
      { 多項式除算の剰余を当該RSブロックの }
      { 誤り訂正コードとする }
      CopyMemory(@ecword[ecwtop], @rswork, ecwlen);
      { データコード語の読み出し位置と }
      { 誤り訂正コード語の書き込み位置を }
      { 次のRSブロック開始位置に移動する }
      Inc(dwtop, dwlen);
      Inc(ecwtop ,ecwlen);
    end;
  end;
end;

{ 入力データをモードに従って符号化する }
function TQRCode.qrEncodeDataWordA: Integer;
var
  p: PByte;
  n, m, len, mode: Integer;
  w: Longword;
begin
  { エラーの場合の戻り値 }
  Result := -1;
  { データコード語を初期化する }
  qrInitDataWord;
  { 入力データを同じ文字クラスの部分に分割して }
  { それぞれの部分について符号化する }
  p := @source;
  len := qrGetSourceRegion(p, Integer(@source[srclen]) - Integer(p), mode);
  while len > 0 do
  begin
    { pからのlenバイトを符号化モードmodeで符号化する }
    { 入力データが長すぎる }
    if qrGetEncodedLength(mode, len) > qrRemainedDataBits then
      Exit;
    { モード指示子(4ビット)を追加する }
    qrAddDataBits(4, modeid[mode]);
    { 文字数指示子(8～16ビット)を追加する }
    { ビット数は型番とモードによって異なる }
    w := Longword(len);
    if mode = QR_EM_KANJI then
      w := w shr 1;
    qrAddDataBits(vertable[FVersion].nlen[mode], w);
    { データ本体を符号化する }
    case mode of
      QR_EM_NUMERIC:
      begin
        { 数字モード }
        { 3桁ずつ10ビットの2進数に変換する }
        { 余りは1桁なら4ビット、2桁なら7ビットにする }
        n := 0;
        w := 0;
        while len > 0 do
        begin
          Dec(len);
          w := w * 10 + Longword(p^ - $30); // $30 = '0'
          Inc(p);
          { 3桁たまったら10ビットで追加する }
          Inc(n);
          if n >= 3 then
          begin
            qrAddDataBits(10, w);
            n := 0;
            w := 0;
          end;
        end;
        { 余りの桁を追加する }
        if n = 1 then
          qrAddDataBits(4, w)
        else if n = 2 then
          qrAddDataBits(7, w);
      end;
      QR_EM_ALNUM:
      begin
        { 英数字モード }
        { 2桁ずつ11ビットの2進数に変換する }
        { 余りは6ビットとして変換する }
        n := 0;
        w := 0;
        while len > 0 do
        begin
          Dec(len);
          w := w * 45 + Longword(Longint(alnumtable[p^]));
          Inc(p);
          { 2桁たまったら11ビットで追加する }
          Inc(n);
          if n >= 2 then
          begin
            qrAddDataBits(11, w);
            n := 0;
            w := 0;
          end;
        end;
        { 余りの桁を追加する }
        if n = 1 then
          qrAddDataBits(6, w);
      end;
      QR_EM_8BIT:
      begin
        { 8ビットバイトモード }
        { 各バイトを直接8ビット値として追加する }
        while len > 0 do
        begin
          Dec(len);
          qrAddDataBits(8, p^);
          Inc(p);
        end;
      end;
      QR_EM_KANJI:
      begin
        { 漢字モード }
        { 2バイトを13ビットに変換して追加する }
        while len >= 2 do
        begin
          { 第1バイトの処理 }
          { $81～$9Fなら$81を引いて$C0を掛ける }
          { $E0～$EBなら$C1を引いて$C0を掛ける }
          if (p^ >= $81) and (p^ <= $9F) then
            w := (p^ - $81) * $C0
          else // if (p^ >= $E0) and (p^ <= $EB)
            w := (p^ - $C1) * $C0;
          Inc(p);
          { 第2バイトの処理 }
          { $40を引いてから第1バイトの結果に加える }
          if ((p^ >= $40) and (p^ <= $7E)) or ((p^ >= $80) and (p^ <= $FC)) then
            w := w + Longword(p^ - $40)
          else
            { JIS X 0208漢字の2バイトめでない }
            Exit;
          Inc(p);
          { 結果を13ビットの値として追加する }
          qrAddDataBits(13, w);
          Dec(len, 2);
        end;
        if len > 0 then
        { 末尾に余分なバイトがある }
          Exit;
      end;
    end;
    len := qrGetSourceRegion(p, Integer(@source[srclen]) - Integer(p), mode);
  end;
  { 終端パターンを追加する(最大4ビットの0) }
  n := qrRemainedDataBits;
  if n < 4 then
  begin
    qrAddDataBits(n, 0);
    n := 0;
  end
  else
  begin
    qrAddDataBits(4, 0);
    Dec(n, 4);
  end;
  { 末尾のデータコード語の全ビットが埋まっていなければ }
  { 余りを埋め草ビット(0)で埋める }
  m := n mod 8;
  if m > 0 then
  begin
    qrAddDataBits(m, 0);
    Dec(n, m);
  end;
  { 残りのデータコード語に埋め草コード語1,2を交互に埋める }
  w := PADWORD1;
  while n >= 8 do
  begin
    qrAddDataBits(8, w);
    if w = PADWORD1 then
      w := PADWORD2
    else
      w := PADWORD1;
    Dec(n, 8);
  end;
  FEmodeR := mode;
  Result := 0;
end;

{ 入力データをモードに従って符号化する }
function TQRCode.qrEncodeDataWordM: Integer;
var
  i: Integer;
  n, m: Integer;
  w: Longword;
begin
  { エラーの場合の戻り値 }
  Result := -1;
  { データコード語を初期化する }
  qrInitDataWord;
  { モード指示子(4ビット)を追加する }
  qrAddDataBits(4, modeid[FEmode]);
  { 文字数指示子(8～16ビット)を追加する }
  { ビット数は型番とモードによって異なる }
  w := Longword(srclen);
  if (FEmode = QR_EM_KANJI) then
    w := w shr 1;
  qrAddDataBits(vertable[version].nlen[FEmode], w);
  { 入力データを符号化する }
  if FEmode = QR_EM_NUMERIC then
  begin
    { 数字モード }
    { 3桁ずつ10ビットの2進数に変換する }
    { 余りは1桁なら4ビット、2桁なら7ビットにする }
    n := 0;
    w := 0;
    i := 0;
    while i < srclen do
    begin
      if (source[i] < $30) or (source[i] > $39) then // $30 = '0', $39 = '9'
        Exit; // 数字でない
      w := w * 10 + Longword(source[i] - $30);       // $30 = '0'
      { 3桁たまったら10ビットで追加する }
      Inc(n);
      if n >= 3 then
      begin
        qrAddDataBits(10, w);
        n := 0;
        w := 0;
      end;
      Inc(i);
    end;
    { 余りの桁を追加する }
    if n = 1 then
      qrAddDataBits(4, w)
    else if n = 2 then
      qrAddDataBits(7, w);
  end
  else if FEmode = QR_EM_ALNUM then
  begin
    { 英数字モード }
    { 2桁ずつ11ビットの2進数に変換する }
    { 余りは6ビットとして変換する }
    n := 0;
    w := 0;
    i := 0;
    while i < srclen do
    begin
      if ((source[i] and $80) <> 0) or (alnumtable[source[i]] = -1) then
        Exit; // 符号化可能な英数字でない
      w := w * 45 + Longword(Longint(alnumtable[source[i]]));
      { 2桁たまったら11ビットで追加する }
      Inc(n);
      if n >= 2 then
      begin
        qrAddDataBits(11, w);
        n := 0;
        w := 0;
      end;
      Inc(i);
    end;
    { 余りの桁を追加する }
    if n = 1 then
      qrAddDataBits(6, w);
  end
  else if FEmode = QR_EM_8BIT then
  begin
    { 8ビットバイトモード }
    { 各バイトを直接8ビット値として追加する }
    i := 0;
    while i < srclen do
    begin
      qrAddDataBits(8, source[i]);
      Inc(i);
    end;
  end
  else if FEmode = QR_EM_KANJI then
  begin
    { 漢字モード }
    { 2バイトを13ビットに変換して追加する }
    i := 0;
    while i < srclen - 1 do
    begin
      { 第1バイトの処理 }
      { $81～$9Fなら$81を引いて$C0を掛ける }
      { $E0～$EBなら$C1を引いて$C0を掛ける }
      if (source[i] >= $81) and (source[i] <= $9F) then
        w := (source[i] - $81) * $C0
      else if (source[i] >= $E0) and (source[i] <= $EB) then
        w := (source[i] - $C1) * $C0
      else
        Exit; // JIS X 0208漢字の1バイトめでない
      Inc(i);
      { 第2バイトの処理 }
      { 0x40を引いてから第1バイトの結果に加える }
      if ((source[i] >= $40) and (source[i] <= $7E)) or
       ((source[i] >= $80) and (source[i] <= $FC)) then
        w := w + source[i] - $40
      else
        Exit; // JIS X 0208漢字の2バイトめでない
      Inc(i);
      { 結果を13ビットの値として追加する }
      qrAddDataBits(13, w);
    end;
    if i < srclen then
      Exit; // 末尾に余分なバイトがある
  end;
  { 終端パターンを追加する(最大4ビットの0) }
  n := qrRemainedDataBits;
  if n < 4 then
  begin
    qrAddDataBits(n, 0);
    n := 0;
  end
  else
  begin
    qrAddDataBits(4, 0);
    Dec(n, 4);
  end;
  { 末尾のデータコード語の全ビットが埋まっていなければ }
  { 余りを埋め草ビット(0)で埋める }
  m := n mod 8;
  if m > 0 then
  begin
    qrAddDataBits(m, 0);
    Dec(n, m);
  end;
  { 残りのデータコード語に埋め草コード語1,2を交互に埋める }
  w := PADWORD1;
  while n >= 8 do
  begin
    qrAddDataBits(8, w);
    if w = PADWORD1 then
      w := PADWORD2
    else
      w := PADWORD1;
    Dec(n, 8);
  end;
  Result := 0;
end;

{ マスクパターンを評価し評価値を返す }
function TQRCode.qrEvaluateMaskPattern: Longint;
var
  i, j, m, n, dim: Integer;
  penalty: Longint;
begin
  { 評価値をpenaltyに積算する }
  { マスクは符号化領域に対してのみ行うが }
  { 評価はシンボル全体について行われる }
  penalty := 0;
  dim := vertable[FVersion].dimension;
  { 特徴: 同色の行/列の隣接モジュール }
  { 評価条件: モジュール数 := (5 ＋ i) }
  { 失点: 3 ＋ i }
  for i := 0 to dim - 1 do
  begin
    n := 0;
    for j := 0 to dim - 1 do
    begin
      if (j > 0) and (isBlack(i, j) = isBlack(i, j - 1)) then
        Inc(n) // すぐ左と同色のモジュール、同色列の長さを1増やす
      else
      begin
        { 色が変わった }
        { 直前で終わった同色列の長さを評価する }
        if n >= 5 then
          penalty := penalty + 3 + (n - 5);
        n := 1;
      end;
    end;
    { 列が尽きた }
    { 直前で終わった同色列の長さを評価する }
    if n >= 5 then
      penalty := penalty + 3 + (n - 5);
  end;
  for i := 0 to dim - 1 do
  begin
    n := 0;
    for j := 0 to dim - 1 do
    begin
      if (j > 0) and (isBlack(j, i) = isBlack(j - 1, i)) then
        Inc(n) // すぐ上と同色のモジュール、同色列の長さを1増やす
      else
      begin
        { 色が変わった }
        { 直前で終わった同色列の長さを評価する }
        if n >= 5 then
          penalty := penalty + 3 + (n - 5);
        n := 1;
      end;
    end;
    { 列が尽きた }
    { 直前で終わった同色列の長さを評価する }
    if n >= 5 then
      penalty := penalty + 3 + (n - 5);
  end;
  { 特徴: 同色のモジュールブロック }
  { 評価条件: ブロックサイズ := 2×2 }
  { 失点: 3 }
  for i := 0 to dim - 2 do
  begin
    for j := 0 to dim - 2 do
    begin
      if (
        (isBlack(i, j) = isBlack(i, j + 1)) and
        (isBlack(i, j) = isBlack(i + 1, j)) and
        (isBlack(i, j) = isBlack(i + 1, j + 1))
      ) then
        Inc(penalty, 3); // 2×2の同色のブロックがあった
    end;
  end;
  { 特徴: 行/列における1:1:3:1:1比率(暗:明:暗:明:暗)のパターン }
  { 失点: 40 }
  { 前後はシンボル境界外か明モジュールである必要がある }
  { 2:2:6:2:2のようなパターンにも失点を与えるべきかは }
  { JIS規格からは読み取れない。ここでは与えていない }
  for i := 0 to dim - 1 do
  begin
    for j := 0 to dim - 7 do
    begin
      if (
        ((j = 0) or (isBlack(i, j - 1) = False)) and
        (isBlack(i, j + 0) = True) and
        (isBlack(i, j + 1) = False) and
        (isBlack(i, j + 2) = True) and
        (isBlack(i, j + 3) = True) and
        (isBlack(i, j + 4) = True) and
        (isBlack(i, j + 5) = False) and
        (isBlack(i, j + 6) = True) and
        ((j = dim-7) or (isBlack(i, j + 7) = False))
      ) then
        Inc(penalty, 40); // パターンがあった
    end;
  end;
  for i := 0 to dim - 1 do
  begin
    for j := 0 to dim - 7 do
    begin
      if (
        ((j = 0) or (isBlack(j - 1, i) = False)) and
        (isBlack(j + 0, i) = True) and
        (isBlack(j + 1, i) = False) and
        (isBlack(j + 2, i) = True) and
        (isBlack(j + 3, i) = True) and
        (isBlack(j + 4, i) = True) and
        (isBlack(j + 5, i) = False) and
        (isBlack(j + 6, i) = True) and
        ((j = dim - 7) or (isBlack(j + 7, i) = False))
      ) then
        Inc(penalty, 40); // パターンがあった
    end;
  end;
  { 特徴: 全体に対する暗モジュールの占める割合 }
  { 評価条件: 50±(5×k)%～50±(5×(k＋1))% }
  { 失点: 10×k }
  m := 0;
  n := 0;
  for i := 0 to dim - 1 do
  begin
    for j := 0 to dim - 1 do
    begin
      Inc(m);
      if isBlack(i, j) = True then
        Inc(n);
    end;
  end;
  penalty := penalty + Abs((n * 100 div m) - 50) div 5 * 10;
  Result := penalty;
end;

{ シンボルに符号化されたコード語を配置する }
procedure TQRCode.qrFillCodeWord;
var
  i, j: Integer;
begin
  { シンボル右下隅から開始する }
  qrInitPosition;
  { コード語領域のすべてのバイトについて... }
  for i := 0 to vertable[FVersion].totalwords - 1 do
  begin
    { 最上位ビットから順に各ビットを調べ... }
    for j := 7 downto 0 do
    begin
      { そのビットが1なら黒モジュールを置く }
      if (codeword[i] and (1 shl j)) <> 0 then
        symbol[ypos][xpos] := symbol[ypos][xpos] or QR_MM_DATA;
      { 次のモジュール配置位置に移動する }
      qrNextPosition;
    end;
  end;
end;

{ シンボルに形式情報と型番情報を配置する }
procedure TQRCode.qrFillFormatInfo;
var
  i, j, dim, fmt, modulo, xpos, ypos: Integer;
  v: Longint;
begin
  dim := vertable[FVersion].dimension;
  { 形式情報を計算する }
  { 誤り訂正レベル2ビット(L:01, M:00, Q:11, H:10)と }
  { マスクパターン参照子3ビットからなる計5ビットに }
  { Bose-Chaudhuri-Hocquenghem(15,5)符号による }
  { 誤り訂正ビット10ビットを付加して15ビットとする }
  { (5ビットをxの次数14～10の多項式係数とみなして }
  { 多項式x^10+x^8+x^5+x^4+x^2+x+1(係数10100110111) }
  { で除算した剰余10ビットを誤り訂正ビットとする) }
  { さらにすべてのビットがゼロにならないように }
  { 101010000010010(0x5412)とXORをとる }
  fmt := ((FEclevel xor 1) shl 3) or FMasktypeR;
  modulo := fmt shl 10;
  for i := 14 downto 10 do
  begin
    if (modulo and (1 shl i)) = 0 then
      continue;
    modulo :=  modulo xor ($0537 shl (i - 10));
  end;
  fmt := ((fmt shl 10) + modulo) xor $5412;
    
  { 形式情報をシンボルに配置する }
  for i := 0 to 1 do
  begin
    for j := 0 to QR_FIN_MAX - 1 do
    begin
      if (fmt and (1 shl j)) = 0 then
        continue;
      xpos := (fmtinfopos[i][j].xpos + dim) mod dim;
      ypos := (fmtinfopos[i][j].ypos + dim) mod dim;
      symbol[ypos][xpos] := symbol[ypos][xpos] or QR_MM_BLACK;
    end;
  end;
  xpos := (fmtblackpos.xpos + dim) mod dim;
  ypos := (fmtblackpos.ypos + dim) mod dim;
  symbol[ypos][xpos] := symbol[ypos][xpos] or QR_MM_BLACK;
  { 型番情報が有効(型番7以上)なら }
  { 型番情報をシンボルに配置する }
  v := verinfo[FVersion];
  if v <> -1 then
  begin
    for i := 0 to 1 do
    begin
      for j := 0 to QR_VIN_MAX - 1 do
      begin
        if (v and (1 shl j)) = 0 then
          continue;
        xpos := (verinfopos[i][j].xpos + dim) mod dim;
        ypos := (verinfopos[i][j].ypos + dim) mod dim;
        symbol[ypos][xpos] := symbol[ypos][xpos] or QR_MM_BLACK;
      end;
    end;
  end;
end;

{ シンボルを初期化し、機能パターンを配置する }
procedure TQRCode.qrFillFunctionPattern;
var
  i, j, n, dim, xpos, ypos: Integer;
  x, y, x0, y0, xcenter, ycenter: Integer;
begin
  { シンボルの1辺の長さを求める }
  dim := vertable[FVersion].dimension;
  { シンボル全体をクリアする }
  ZeroMemory(@symbol, SizeOf(symbol));
  { 左上、右上、左下の隅に位置検出パターンを配置する }
  for i := 0 to QR_DIM_FINDER - 1 do
  begin
    for j := 0 to QR_DIM_FINDER - 1 do
    begin
      symbol[i][j] := finderpattern[i][j];
      symbol[i][dim - 1 - j] := finderpattern[i][j];
      symbol[dim - 1 - i][j] := finderpattern[i][j];
    end;
  end;
  { 位置検出パターンの分離パターンを配置する }
  for i := 0 to QR_DIM_FINDER do
  begin
    symbol[i][QR_DIM_FINDER] := QR_MM_FUNC;
    symbol[QR_DIM_FINDER][i] := QR_MM_FUNC;
    symbol[i][dim - 1 - QR_DIM_FINDER] := QR_MM_FUNC;
    symbol[dim - 1 - QR_DIM_FINDER][i] := QR_MM_FUNC;
    symbol[dim - 1 - i][QR_DIM_FINDER] := QR_MM_FUNC;
    symbol[QR_DIM_FINDER][dim - 1 - i] := QR_MM_FUNC;
  end;
  { 位置合わせパターンを配置する }
  n := vertable[FVersion].aplnum;
  for i := 0 to n - 1 do
  begin
    for j := 0 to n - 1 do
    begin
      { 位置合わせパターンの中心と左上の座標を求める }
      ycenter := vertable[FVersion].aploc[i];
      xcenter := vertable[FVersion].aploc[j];
      y0 := ycenter - QR_DIM_ALIGN div 2;
      x0 := xcenter - QR_DIM_ALIGN div 2;
      if isFunc(ycenter, xcenter) = True then
        Continue; // 位置検出パターンと重なるときは配置しない
      for y := 0 to QR_DIM_ALIGN - 1 do
      begin
        for x := 0 to QR_DIM_ALIGN - 1 do
          symbol[y0 + y][x0 + x] := alignpattern[y][x];
      end;
    end;
  end;
  { タイミングパターンを配置する }
  for i := QR_DIM_FINDER to dim - 1 - QR_DIM_FINDER - 1 do
  begin
    symbol[i][QR_DIM_TIMING] := QR_MM_FUNC;
    symbol[QR_DIM_TIMING][i] := QR_MM_FUNC;
    if (i and 1) = 0 then
    begin
      symbol[i][QR_DIM_TIMING] := symbol[i][QR_DIM_TIMING] or QR_MM_BLACK;
      symbol[QR_DIM_TIMING][i] := symbol[QR_DIM_TIMING][i] or QR_MM_BLACK;
    end;
  end;
  { 形式情報の領域を予約する }
  for i := 0 to 1 do
  begin
    for j := 0 to QR_FIN_MAX - 1 do
    begin
      xpos := (fmtinfopos[i][j].xpos + dim) mod dim;
      ypos := (fmtinfopos[i][j].ypos + dim) mod dim;
      symbol[ypos][xpos] := symbol[ypos][xpos] or QR_MM_FUNC;
    end;
  end;
  xpos := (fmtblackpos.xpos + dim) mod dim;
  ypos := (fmtblackpos.ypos + dim) mod dim;
  symbol[ypos][xpos] := symbol[ypos][xpos] or QR_MM_FUNC;
  { 型番情報が有効(型番7以上)なら }
  { 型番情報の領域を予約する }
  if verinfo[FVersion] <> -1 then
  begin
    for i := 0 to 1 do
    begin
      for j := 0 to QR_VIN_MAX - 1 do
      begin
        xpos := (verinfopos[i][j].xpos + dim) mod dim;
        ypos := (verinfopos[i][j].ypos + dim) mod dim;
        symbol[ypos][xpos] := symbol[ypos][xpos] or QR_MM_FUNC;
      end;
    end;
  end;
end;

{ 特定のモードでlenバイト符号化したときのビット長を返す }
function TQRCode.qrGetEncodedLength(mode: Integer; len: Integer): Integer;
var
  n: Integer;
begin
  { モード指示子と文字数指示子のサイズ }
  n := 4 + vertable[FVersion].nlen[mode];
  { 符号化モードごとのデータサイズ }
  case mode of
    QR_EM_NUMERIC:
    begin
      { 数字モード: 3桁ごとに10ビット }
      { (余りは1桁なら4ビット, 2桁なら7ビット) }
      n := n + (len div 3) * 10;
      case (len mod 3) of
        1: Inc(n, 4);
        2: Inc(n, 7);
      end;
    end;
    QR_EM_ALNUM:
    begin
      { 英数字モード: 2桁ごとに11ビット }
      { (余りは1桁につき6ビット) }
      n := n + (len div 2) * 11;
      if (len mod 2) = 1 then
        Inc(n, 6);
    end;
    QR_EM_8BIT:
      { 8ビットバイトモード: 1桁ごとに8ビット }
      n := n + len * 8;
    QR_EM_KANJI:
      { 漢字モード: 1文字(2バイト)ごとに13ビット }
      n := n + (len div 2) * 13;
  end;
  Result := n;
end;

{ どの符号化モードで何バイト符号化すべきか求める }
function TQRCode.qrGetSourceRegion(src: PByte; len: Integer; var mode: Integer): Integer;
var
  n, m, cclass, ccnext: Integer;
  HasData: Boolean;
begin
  Result := 0;
  { 入力データがない }
  { バイト数ゼロを返す }
  if len = 0 then
    Exit;
  { 残りの入力データの先頭から同じ符号化モードで }
  { 何バイトのデータを符号化すればよいか調べる }
  HasData := True;
  cclass := charclass[src^];
  n := 0;
  while HasData do
  begin
    { 同じ文字クラスの文字が何バイト続くか調べる }
    while (len > 0) and (charclass[src^] = cclass) do
    begin
      if cclass = QR_EM_KANJI then
      begin
        Inc(src, 2);
        Dec(len, 2);
        Inc(n, 2);
      end
      else
      begin
        Inc(src);
        Dec(len);
        Inc(n);
      end;
    end;
    if (len = 0) then
    begin
      { 入力データが尽きた }
      { 符号化モードとバイト数を返す }
      mode := cclass;
      Result := n;
      Exit;
    end;
    ccnext := charclass[src^];
    if (cclass = QR_EM_KANJI) or (ccnext = QR_EM_KANJI) then
    begin
      { 漢字クラスからそれ以外のクラスへ、または }
      { 漢字以外のクラスから漢字クラスへ変化した }
      { 符号化モードの切り替えが必要になるので }
      { ここまでの符号化モードとバイト数を返す }
      mode := cclass;
      Result := n;
      Exit;
    end;
    if cclass > ccnext then
    begin
      { 下位の文字クラスに変化した(8ビット→英数字, }
      { 8ビット→数字, 英数字→数字) }
      { ここで符号化モードを切り替えたほうが有利か }
      { 切り替えず続けたほうが有利か調べる }
      m := 0;
      while (len > 0) and (charclass[src^] = ccnext) do
      begin
        Inc(src);
        Dec(len);
        Inc(m);
      end;
      if (len > 0) and (charclass[src^] = cclass) then
      begin
        { 最初の文字クラスに戻った }
        { 符号化モードを切り替えてまた戻した場合と }
        { 切り替えなかった場合について }
        { 符号化ビット数の合計を比較する }
        if (qrGetEncodedLength(cclass, n) + qrGetEncodedLength(ccnext, m) +
         qrGetEncodedLength(cclass, 0)) < qrGetEncodedLength(cclass, n + m) then
        begin
          { 切り替えたほうが短くなる }
          { 最初の文字クラスの部分について }
          { 符号化モードとバイト数を返す }
          mode := cclass;
          Result := n;
          Exit;
        end
        else
        begin
          { 切り替えないほうが短くなる }
          { 最初の文字クラスが続くとみなして }
          { カウントを続ける }
          Inc(n, m);
          Continue;
        end;
      end
      else
      begin
        { データが尽きたか別の文字クラスに変わった }
        { 符号化モードを切り替えた場合と }
        { 切り替えなかった場合について }
        { 符号化ビット数の合計を比較する }
        if (qrGetEncodedLength(cclass, n) + qrGetEncodedLength(ccnext, m))
         < qrGetEncodedLength(cclass, n + m) then
        begin
          { 切り替えたほうが短くなる }
          { 最初の文字クラスの部分について }
          { 符号化モードとバイト数を返す }
          mode := cclass;
          Result := n;
          Exit;
        end
        else
        begin
          { 切り替えないほうが短くなる }
          { 最初の文字クラスが続くとみなして }
          { カウントを続ける }
          Inc(n, m);
          Continue;
        end;
      end;
    end
    else if cclass < ccnext then
    begin
      { より上位の文字クラスに変化した(数字→英数字, }
      { 数字→8ビット, 英数字→8ビット) }
      { ここで符号化モードを切り替えたほうが有利か、}
      { 先に切り替えておいたほうが有利か調べる }
      m := 0;
      while (len > 0) and (charclass[src^] = ccnext) do
      begin
        Inc(src);
        Dec(len);
        Inc(m);
      end;
      if (qrGetEncodedLength(cclass, n) + qrGetEncodedLength(ccnext, m))
       < qrGetEncodedLength(ccnext, n + m) then
      begin
        { ここで切り替えたほうが短くなる }
        { 最初の文字クラスの部分について }
        { 符号化モードとバイト数を返す }
        mode := cclass;
        Result := n;
        Exit;
      end
      else
      begin
        { 先に切り替えておいたほうが短くなる }
        { 全体を後続の文字クラスと見なして }
        { 符号化モードとバイト数を返す }
        mode := ccnext;
        Result := n + m;
        Exit;
      end;
    end;
  end;
end;

{ データコード語を初期化する }
procedure TQRCode.qrInitDataWord;
begin
  { データコード語領域をゼロクリアする }
  ZeroMemory(@dataword, SizeOf(dataword));
  { 追加位置をバイト0の最上位ビットにする }
  dwpos := 0;
  dwbit := 7;
end;

{ モジュール配置の初期位置と配置方向を決める }
procedure TQRCode.qrInitPosition;
begin
  { シンボルの右下隅から配置を始める }
  xpos := vertable[FVersion].dimension - 1;
  ypos := xpos;
  { 最初の移動方向は左向き、次に上向き }
  xdir := -1;
  ydir := -1;
end;

{ データコード語と誤り訂正コード語から最終的なコード語を作る }
procedure TQRCode.qrMakeCodeWord;
var
  i, j, k, cwtop, pos: Integer;
  dwlenmax, ecwlenmax: Integer;
  dwlen, ecwlen, nrsb: Integer;
begin
  { RSブロックのサイズ種類数(nrsb)および }
  { 最大RSブロックのデータコード語数(dwlenmax)、}
  { 誤り訂正コード語数(ecwlenmax)を得る }
  nrsb := vertable[FVersion].ecl[FEclevel].nrsb;
  dwlenmax := vertable[FVersion].ecl[FEclevel].rsb[nrsb - 1].datawords;
  ecwlenmax := vertable[FVersion].ecl[FEclevel].rsb[nrsb - 1].totalwords
               - vertable[FVersion].ecl[FEclevel].rsb[nrsb - 1].datawords;
  { 各RSブロックから順にデータコード語を取り出し }
  { コード語領域(codeword)に追加する }
  cwtop := 0;
  for i := 0 to dwlenmax - 1 do
  begin
    pos := i;
    { RSブロックのサイズごとに処理を行う }
    for j := 0 to nrsb - 1 do
    begin
      dwlen := vertable[FVersion].ecl[FEclevel].rsb[j].datawords;
      { 同じサイズのRSブロックは順に処理する }
      for k := 0 to vertable[FVersion].ecl[FEclevel].rsb[j].rsbnum - 1 do
      begin
        { 各RSブロックのiバイトめのデータ }
        { コード語をコード語領域に追加する }
        { (すでにすべてのデータコード語を }
        { 取り出したRSブロックは飛ばす) }
        if i < dwlen then
        begin
          codeword[cwtop] := dataword[pos];
          Inc(cwtop);
        end;
        { 次のRSブロックのiバイトめに進む }
        Inc(pos, dwlen);
      end;
    end;
  end;
  { 各RSブロックから順に誤り訂正コード語を取り出し }
  { コード語領域(codeword)に追加する }
  for i := 0 to ecwlenmax - 1 do
  begin
    pos := i;
    { RSブロックのサイズごとに処理を行う }
    for j := 0 to nrsb - 1 do
    begin
      ecwlen := vertable[FVersion].ecl[FEclevel].rsb[j].totalwords
                - vertable[FVersion].ecl[FEclevel].rsb[j].datawords;
      { 同じサイズのRSブロックは順に処理する }
      for k := 0 to vertable[FVersion].ecl[FEclevel].rsb[j].rsbnum - 1 do
      begin
        { 各RSブロックのiバイトめの誤り訂正 }
        { コード語をコード語領域に追加する }
        { (すでにすべての誤り訂正コード語を }
        { 取り出したRSブロックは飛ばす) }
        if i < ecwlen then
        begin
          codeword[cwtop] := ecword[pos];
          Inc(cwtop);
        end;
        { 次のRSブロックのiバイトめに進む }
        Inc(pos, ecwlen);
      end;
    end;
  end;
end;

{ 次のモジュール配置位置を決める }
procedure TQRCode.qrNextPosition;
begin
  repeat
    { xdir方向に1モジュール移動して }
    { xdirの向きを逆にする }
    { 右に移動したときはydir方向にも }
    { 1モジュール移動する }
    Inc(xpos ,xdir);
    if xdir > 0 then
      Inc(ypos ,ydir);
    xdir := -xdir;
    { y方向にシンボルをはみ出すようなら }
    { y方向ではなくx方向に2モジュール左に移動し、}
    { かつydirの向きを逆にする }
    { xposが縦のタイミングパターン上なら }
    { さらに1モジュール左に移動する }
    if (ypos < 0) or (ypos >= vertable[FVersion].dimension) then
    begin
      Dec(ypos ,ydir);
      ydir := -ydir;
      Dec(xpos ,2);
      if xpos = QR_DIM_TIMING then
        Dec(xpos);
    end;
  { 新しい位置が機能パターン上なら }
  { それをよけて次の候補位置を探す }
  until isFunc(ypos, xpos) = False;
end;

{ 生成されたQRコードシンボルを出力する }
procedure TQRCode.qrOutputSymbol;
var
  i, j, ix, jx, dim, imgdim: Integer;
  p: String;
  q: String;
begin
  { 生成されたQRコードシンボルをモノクロ2値の }
  { アスキー形式Portable Bitmap(PBM)として出力する }
  { 縦横ともにFPxmagで指定した倍率で出力する }
  FPBM.Clear;
  dim := vertable[FVersion].dimension;
  imgdim := (dim + QR_DIM_SEP * 2) * FPxmag; // シンボルの大きさ(モジュール単位)
  p := 'P1'; FPBM.Add(p);
  p := IntToStr(imgdim); FPBM.Add(p + ' ' + p);
  { 分離パターンで囲んでシンボルを書く }
  for i := 0 to QR_DIM_SEP * FPxmag - 1 do
  begin
    p := '';
    for j := 0 to imgdim - 1 do
      p := p + ' 0';
    FPBM.Add(p);
  end;
  for i := 0 to dim - 1 do
  begin
    for ix := 0 to FPxmag - 1 do
    begin
      p := '';
      for j := 0 to QR_DIM_SEP * FPxmag - 1 do
        p := p + ' 0';
      for j := 0 to dim - 1 do
      begin
        if isBlack(i, j) = True then
          q := ' 1'
        else
          q := ' 0';
        for jx := 0 to FPxmag - 1 do
            p := p + q;
      end;
      for j := 0 to QR_DIM_SEP * FPxmag - 1 do
        p := p + ' 0';
      FPBM.Add(p);
    end;
  end;
  for i := 0 to QR_DIM_SEP * FPxmag - 1 do
  begin
    p := '';
    for j := 0 to imgdim - 1 do
      p := p + ' 0';
    FPBM.Add(p);
  end;
end;

{ データコード語の残りビット数を返す }
function TQRCode.qrRemainedDataBits: Integer;
begin
  Result := (vertable[FVersion].ecl[FEclevel].datawords - dwpos) * 8 - (7 - dwbit);
end;

{ シンボルを最適なマスクパターンでマスクする }
procedure TQRCode.qrSelectMaskPattern;
var
  mask, xmask: Integer;
  penalty, xpenalty: Longint;
begin
  if FMasktype >= 0 then
  begin
    { マスクパターンが引数で指定されていたので }
    { そのパターンでマスクして終了 }
    qrSetMaskPattern(FMasktype);
    Exit;
  end;
  { すべてのマスクパターンを評価する }
  xmask := 0;
  xpenalty := -1;
  for mask := 0 to QR_MPT_MAX - 1 do
  begin
    { 当該マスクパターンでマスクして評価する }
    qrSetMaskPattern(mask);
    penalty := qrEvaluateMaskPattern;
    { 失点がこれまでより低かったら記録する }
    if (xpenalty = -1) or (penalty < xpenalty) then
    begin
      xmask := mask;
      xpenalty := penalty;
    end;
  end;
  { 失点が最低のパターンでマスクする }
  FMasktypeR := xmask;
  qrSetMaskPattern(xmask);
end;

{ 指定した参照子のマスクパターンでシンボルをマスクする }
procedure TQRCode.qrSetMaskPattern(mask: Integer);
var
  i, j, dim: Integer;
begin
  dim := vertable[FVersion].dimension;
  { 以前のマスクパターンをクリアし、}
  { 符号化済みデータを初期パターンとする }
  for i := 0 to dim - 1 do
  begin
    for j := 0 to dim - 1 do
    begin
      { 機能パターン領域の印字黒モジュールは残す }
      if isFunc(i, j) = True then
        Continue;
      { 符号化データ領域は符号化データの }
      { 黒モジュールを印字黒モジュールにする }
      if isData(i, j) = True then
        symbol[i][j] := symbol[i][j] or QR_MM_BLACK
      else
        symbol[i][j] := symbol[i][j] and (not QR_MM_BLACK);
    end;
  end;
  { i行j列のモジュールについて... }
  for i := 0 to dim - 1 do
  begin
    for j := 0 to dim - 1 do
    begin
      { 機能パターン領域(および形式情報、}
      { 型番情報)はマスク対象から除外する }
      if isFunc(i, j) = True then
        Continue;
      { 指定された条件を満たすモジュールを反転する }
      if (
        ((mask = 0) and ((i + j) mod 2 = 0)) or
        ((mask = 1) and (i mod 2 = 0)) or
        ((mask = 2) and (j mod 3 = 0)) or
        ((mask = 3) and ((i + j) mod 3 = 0)) or
        ((mask = 4) and (((i div 2) + (j div 3)) mod 2 = 0)) or
        ((mask = 5) and ((i * j) mod 2 + (i * j) mod 3 = 0)) or
        ((mask = 6) and (((i * j) mod 2 + (i * j) mod 3) mod 2 = 0)) or
        ((mask = 7) and (((i * j) mod 3 + (i + j) mod 2) mod 2 = 0))
      ) then
        symbol[i][j] := symbol[i][j] xor QR_MM_BLACK;
    end;
  end;
end;

{ 現在のプロパティの値でバーコードを再描画するメソッドです。}
{ バーコードの上に何か図形を描いた後でバーコードを再描画する }
{ 場合等に使用します。}
procedure TQRCode.RepaintSymbol;
begin
  PaintSymbolCode;
end;

{ 2001/07/29 Created by M&I from here }
//メタファイルコピー手続き
procedure TQRCode.SaveToClipAsWMF(const mf: TMetafile);
var
  hMetafilePict: THandle;
  pMFPict: PMetafilePict;
  DC: THandle;
  Length: Integer;
  Bits: Pointer;
  h: HMETAFILE;
begin
  DC := GetDC(0);
  try
    Length := GetWinMetaFileBits(mf.Handle, 0, nil,
                                 MM_ANISOTROPIC, DC);
    //Assertは論理式が成立しない場合に例外を発生させるため
    //処理を簡略化出来ることがある。
    //代りに条件式でチェックすればＯＫ
    //Assert(Length > 0);
    if Length > 0 then
    begin
      GetMem(Bits, Length);
      try
        GetWinMetaFileBits(mf.Handle, Length, Bits,
                      MM_ANISOTROPIC, DC);
        h := SetMetafileBitsEx(Length, Bits);
        //Assert(h <> 0);
        if h <> 0 then
        begin
          try
            hMetafilePict := GlobalAlloc(GMEM_MOVEABLE or
                                         GMEM_DDESHARE,
                                         Length);
            //Assert(hMetafilePict <> 0);
            if hMetafilePict <> 0 then
            begin
              try
                pMFPict := GlobalLock(hMetafilePict);
                pMFPict^.mm := MM_ANISOTROPIC;
                pMFPict^.xExt := mf.MMWidth;
                pMfPict^.yExt := mf.MMHeight;
                pMfPict^.hMF  := h;
                GlobalUnlock(hMetafilePict);

                Clipboard.SetAsHandle(CF_METAFILEPICT, hMetafilePict);
              except
                GlobalFree(hMetafilePict);
                raise;
              end;
            end;
          except
            DeleteObject(h);
            raise;
          end;
        end;
      finally
        FreeMem(Bits);
      end;
    end;
  finally
    ReleaseDC(0, DC);
  end;
end;

procedure TQRCode.SetBackColor(const Value: TColor);
begin
  FBackColor := Value;
  PaintSymbolCode;
end;

procedure TQRCode.SetClearOption(const Value: Boolean);
begin
  if Value = False then
    FClearOption := Value
  else
  begin
    if FClearOption = False then
    begin
      FClearOption := Value;
      if FSymbolDisped = False then
        Clear;
    end;
  end;
end;

{ ClipWatch プロパティを False から True にすると、クリップボードに }
{ 変化がなくとも必ず OnClipChange イベントが一回発生するので、この }
{ 最初のイベントをスキップする必要がある。}
procedure TQRCode.SetClipWatch(const Value: Boolean);
begin
  if (FClipWatch = False) and (Value = True) then
    FSkip := True
  else
    FSkip := False;

  FClipWatch := Value;
  UpdateClip;
end;

procedure TQRCode.SetCode(const Value: String);
begin
  FCode := Value;
  srclen := Length(FCode);
  CopyMemory(@source, PChar(FCode), srclen);
  PaintSymbolCode; // シンボルを描画する
end;

procedure TQRCode.SetComFont(const Value: TFont);
begin
  if (Value <> nil) and (Value <> FComFont) then
  begin
    FComFont.Assign(Value);
    PaintSymbolCode;
  end;
end;

procedure TQRCode.SetCommentDown(const Value: String);
begin
  FCommentDown := Value;
  PaintSymbolCode;
end;

procedure TQRCode.SetCommentDownLoc(const Value: TLocations);
begin
  FCommentDownLoc := Value;
  if FCommentDown <> '' then
    PaintSymbolCode;
end;

procedure TQRCode.SetCommentUp(const Value: String);
begin
  FCommentUp := Value;
  PaintSymbolCode;
end;

procedure TQRCode.SetCommentUpLoc(const Value: TLocations);
begin
  FCommentUpLoc := Value;
  if FCommentUp <> '' then
    PaintSymbolCode;
end;

procedure TQRCode.SetEclevel(const Value: Integer);
begin
  if Value in [0..QR_ECL_MAX - 1] then
  begin
    FEclevel := Value;
    PaintSymbolCode;
  end;
end;

procedure TQRCode.SetEmode(const Value: Integer);
begin
  if (Value in [0..QR_EM_MAX - 1]) or (Value = -1) then
  begin
    FEmode := Value;
    FEmodeR := FEmode;
    PaintSymbolCode;
  end;
end;

procedure TQRCode.SetMasktype(const Value: Integer);
begin
  if (Value in [0..QR_MPT_MAX - 1]) or (Value = -1) then
  begin
    FMasktype := Value;
    FMasktypeR := FMasktype;
    PaintSymbolCode;
  end;
end;

procedure TQRCode.SetMatch(const Value: Boolean);
begin
  FMatch := Value;
  if FMatch = True then
  begin
    if FTransparent = True then
      FTransparent := False;
  end
  else
    FSymbolPicture := psymBMP;
  PaintSymbolCode;
end;

procedure TQRCode.SetOnClipChange(const Value: TNotifyEvent);
begin
  FOnClipChange := Value;
  UpdateClip;
end;

procedure TQRCode.SetPxmag(const Value: Integer);
begin
  if Value in [1..10] then
  begin
    FPxmag := Value;
    PaintSymbolCode;
  end;
end;

procedure TQRCode.SetSymbolColor(const Value: TColor);
begin
  FSymbolColor := Value;
  PaintSymbolCode;
end;

procedure TQRCode.SetSymbolDebug(const Value: Boolean);
begin
  FSymbolDebug := Value
end;

procedure TQRCode.SetSymbolEnabled(const Value: Boolean);
begin
  if FSymbolEnabled <> Value then
  begin
    FSymbolEnabled := Value;
    if FSymbolEnabled = True then
      PaintSymbolCode;
  end;
end;

procedure TQRCode.SetSymbolLeft(const Value: Integer);
begin
  FSymbolLeft := Value;
  PaintSymbolCode;
end;

procedure TQRCode.SetSymbolPicture(const Value: TSymbolPictures);
begin
  if FMatch = False then
    FSymbolPicture := psymBMP
  else
  begin
    FSymbolPicture := Value;
    PaintSymbolCode;
  end;
end;

procedure TQRCode.SetSymbolSpaceDown(const Value: Integer);
begin
  FSymbolSpaceDown := Value;
  PaintSymbolCode;
end;

procedure TQRCode.SetSymbolSpaceLeft(const Value: Integer);
begin
  FSymbolSpaceLeft := Value;
  PaintSymbolCode;
end;

procedure TQRCode.SetSymbolSpaceRight(const Value: Integer);
begin
  FSymbolSpaceRight := Value;
  PaintSymbolCode;
end;

procedure TQRCode.SetSymbolSpaceUp(const Value: Integer);
begin
  FSymbolSpaceUp := Value;
  PaintSymbolCode;
end;

procedure TQRCode.SetSymbolTop(const Value: Integer);
begin
  FSymbolTop := Value;
  PaintSymbolCode;
end;

procedure TQRCode.SetTransparent(const Value: Boolean);
begin
  FTransparent := Value;
  if FTransparent = True then
  begin
    if FMatch = True then
      FMatch := False;
    FSymbolPicture := psymBMP;
  end;
  PaintSymbolCode;
end;

procedure TQRCode.SetVersion(const Value: Integer);
begin
  if Value in [1..QR_VER_MAX] then
  begin
    FVersion := Value;
    PaintSymbolCode;
  end;
end;

procedure TQRCode.UpdateClip;
begin
  if FRegistered = FClipWatch and Assigned(FOnClipChange) then
    Exit;
  FRegistered := not FRegistered;
  if FRegistered then
    FNextWindowHandle := SetClipboardViewer(FWindowHandle)
  else
    ChangeClipboardChain(FWindowHandle, FNextWindowHandle);
end;

procedure TQRCode.WndClipProc(var Message: TMessage);
begin
  with Message do
    case Msg of
      WM_CHANGECBCHAIN:
        try
          with TWMChangeCBChain(Message) do
            if Remove = FNextWindowHandle then
              FNextWindowHandle := Next
            else if FNextWindowHandle <> 0 then
              SendMessage(FNextWindowHandle, Msg, wParam, lParam);
        except
          Application.HandleException(Self);
        end;
      WM_DRAWCLIPBOARD:
        try
          ClipChange; // OnClipChange イベントをここで発生
          SendMessage(FNextWindowHandle, Msg, wParam, lParam);
        except
          Application.HandleException(Self);
        end;
    else
      Result := DefWindowProc(FWindowHandle, Msg, wParam, lParam);
    end;
end;

end.


