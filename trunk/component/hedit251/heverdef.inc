(*********************************************************************

  heverdef.inc

  start  2001/07/16
  update 2002/08/31

  --------------------------------------------------------------------
  このインクルードファイルは SynEdit http://synedit.sourceforge.net/
  を参考にさせて頂きました。

  Delphi1      VER80
  Delphi2      VER90
  C++Builder1  VER93
  Delphi3      VER100
  C++Builder3  VER110
  Delphi4      VER120
  C++Builder4  VER125
  Delphi5      VER130
  C++Builder5  VER130
  Delphi6      VER140
  Delphi7      VER150
    Delphi8         VER160
    Delphi2005      VER170
    BDS2006         VER180
    Delphi2007      VER185

  --------------------------------------------------------------------
  以下の条件シンボルが定義されています。

  COMP1        Delphi1
  COMP1_UP     Delphi1 以上
  COMP2        Delphi2, C++Builder1
  COMP2_UP     Delphi2 以上, C++Builder1 以上
  COMP3        Delphi3, C++Builder3
  COMP3_UP     Delphi3 以上, C++Builder3 以上
  COMP4        Delphi4, C++Builder4
  COMP4_UP     Delphi4 以上, C++Builder4 以上
  COMP5        Delphi5, C++Builder5
  COMP5_UP     Delphi5 以上, C++Builder5 以上
  COMP6        Delphi6
  COMP6_UP     Delphi6 以上
  COMP7        Delphi7
  COMP7_UP     Delphi7 以上
  DELPHI1      Delphi1
  DELPHI1_UP   Delphi1 以上
  DELPHI2      Delphi2
  DELPHI2_UP   Delphi2 以上
  DELPHI3      Delphi3
  DELPHI3_UP   Delphi3 以上
  DELPHI4      Delphi4
  DELPHI4_UP   Delphi4 以上
  DELPHI5      Delphi5
  DELPHI5_UP   Delphi5 以上
  DELPHI6      Delphi6
  DELPHI6_UP   Delphi6 以上
  DELPHI7      Delphi7
  DELPHI7_UP   Delphi7 以上
  BCB1         C++Builder1
  BCB1_UP      C++Builder1 以上
  BCB3         C++Builder3
  BCB3_UP      C++Builder3 以上
  BCB4         C++Builder4
  BCB4_UP      C++Builder4 以上
  BCB5         C++Builder5
  BCB5_UP      C++Builder5 以上

  --------------------------------------------------------------------
  C++Builder 3 以降の場合、$ObjExportAll On が指定されます

  --------------------------------------------------------------------
  Delphi 4, C++Builder 3 以降では、TList.Clear が virtual になっている
  ことに対応するために TLIST_CLEAR_VIRTUAL が定義されます

  --------------------------------------------------------------------
  また、以下のコンパイラ指令が指定されています

  V+  VAR 文字列の厳密処理
  B-  完全な論理評価
  X+  拡張構文
  T-  型付き @ 演算子
  P+  オープンパラメータ
  H+  長い文字列を使う
  J+  型付き定数への代入

*********************************************************************)
//Delphi2007      VER185
{$IFDEF VER185}
  {$DEFINE COMP11}
  {$DEFINE DELPHI2007}
{$ENDIF}
//BDS2006         VER180
{$IFDEF VER180}
  {$DEFINE COMP10}
  {$DEFINE DELPHI2006}
{$ENDIF}
//Delphi2005      VER170
{$IFDEF VER170}
  {$DEFINE COMP9}
  {$DEFINE DELPHI2005}
{$ENDIF}
//Delphi8         VER160
{$IFDEF VER160}
  {$DEFINE COMP8}
  {$DEFINE DELPHI8}
{$ENDIF}

// Delphi 7
{$IFDEF VER150}
  {$DEFINE COMP7}
  {$DEFINE DELPHI7}
{$ENDIF}

// Delphi 6
{$IFDEF VER140}
  {$DEFINE COMP6}
  {$DEFINE DELPHI6}
{$ENDIF}

// Delphi 5, C++Builder 5
{$IFDEF VER130}
  {$DEFINE COMP5}
  {$DEFINE BCB5}
  {$DEFINE DELPHI5}
{$ENDIF}

// C++Builder 4
{$IFDEF VER125}
  {$DEFINE COMP4}
  {$DEFINE BCB4}
{$ENDIF}

// Delphi 4
{$IFDEF VER120}
  {$DEFINE COMP4}
  {$DEFINE DELPHI4}
{$ENDIF}

// C++Builder 3
{$IFDEF VER110}
  {$DEFINE COMP3}
  {$DEFINE BCB3}
{$ENDIF}

// Delphi 3
{$IFDEF VER100}
  {$DEFINE COMP3}
  {$DEFINE DELPHI3}
{$ENDIF}

// C++Builder 1
{$IFDEF VER93}
  {$DEFINE COMP2}
  {$DEFINE BCB1}
{$ENDIF}

// Delphi 2
{$IFDEF VER90}
  {$DEFINE COMP2}
  {$DEFINE DELPHI2}
{$ENDIF}

// Delphi 1
{$IFDEF VER80}
  {$DEFINE COMP1}
  {$DEFINE DELPHI1}
{$ENDIF}

// COMPx_UP
{$IFDEF COMP1}
  {$DEFINE COMP1_UP}
{$ENDIF}

{$IFDEF COMP2}
  {$DEFINE COMP1_UP}
  {$DEFINE COMP2_UP}
{$ENDIF}

{$IFDEF COMP3}
  {$DEFINE COMP1_UP}
  {$DEFINE COMP2_UP}
  {$DEFINE COMP3_UP}
{$ENDIF}

{$IFDEF COMP4}
  {$DEFINE COMP1_UP}
  {$DEFINE COMP2_UP}
  {$DEFINE COMP3_UP}
  {$DEFINE COMP4_UP}
{$ENDIF}

{$IFDEF COMP5}
  {$DEFINE COMP1_UP}
  {$DEFINE COMP2_UP}
  {$DEFINE COMP3_UP}
  {$DEFINE COMP4_UP}
  {$DEFINE COMP5_UP}
{$ENDIF}

{$IFDEF COMP6}
  {$DEFINE COMP1_UP}
  {$DEFINE COMP2_UP}
  {$DEFINE COMP3_UP}
  {$DEFINE COMP4_UP}
  {$DEFINE COMP5_UP}
  {$DEFINE COMP6_UP}
{$ENDIF}

{$IFDEF COMP7}
  {$DEFINE COMP1_UP}
  {$DEFINE COMP2_UP}
  {$DEFINE COMP3_UP}
  {$DEFINE COMP4_UP}
  {$DEFINE COMP5_UP}
  {$DEFINE COMP6_UP}
  {$DEFINE COMP7_UP}
{$ENDIF}

{$IFDEF COMP8}
  {$DEFINE COMP1_UP}
  {$DEFINE COMP2_UP}
  {$DEFINE COMP3_UP}
  {$DEFINE COMP4_UP}
  {$DEFINE COMP5_UP}
  {$DEFINE COMP6_UP}
  {$DEFINE COMP7_UP}
  {$DEFINE COMP8_UP}
{$ENDIF}

{$IFDEF COMP9}
  {$DEFINE COMP1_UP}
  {$DEFINE COMP2_UP}
  {$DEFINE COMP3_UP}
  {$DEFINE COMP4_UP}
  {$DEFINE COMP5_UP}
  {$DEFINE COMP6_UP}
  {$DEFINE COMP7_UP}
  {$DEFINE COMP8_UP}
  {$DEFINE COMP9_UP}
{$ENDIF}

{$IFDEF COMP10}
  {$DEFINE COMP1_UP}
  {$DEFINE COMP2_UP}
  {$DEFINE COMP3_UP}
  {$DEFINE COMP4_UP}
  {$DEFINE COMP5_UP}
  {$DEFINE COMP6_UP}
  {$DEFINE COMP7_UP}
  {$DEFINE COMP8_UP}
  {$DEFINE COMP10_UP}
{$ENDIF}

{$IFDEF COMP11}
  {$DEFINE COMP1_UP}
  {$DEFINE COMP2_UP}
  {$DEFINE COMP3_UP}
  {$DEFINE COMP4_UP}
  {$DEFINE COMP5_UP}
  {$DEFINE COMP6_UP}
  {$DEFINE COMP7_UP}
  {$DEFINE COMP8_UP}
  {$DEFINE COMP11_UP}
{$ENDIF}

// DELPHIx_UP
{$IFDEF DELPHI1}
  {$DEFINE DELPHI1_UP}
{$ENDIF}

{$IFDEF DELPHI2}
  {$DEFINE DELPHI1_UP}
  {$DEFINE DELPHI2_UP}
{$ENDIF}

{$IFDEF DELPHI3}
  {$DEFINE DELPHI1_UP}
  {$DEFINE DELPHI2_UP}
  {$DEFINE DELPHI3_UP}
{$ENDIF}

{$IFDEF DELPHI4}
  {$DEFINE DELPHI1_UP}
  {$DEFINE DELPHI2_UP}
  {$DEFINE DELPHI3_UP}
  {$DEFINE DELPHI4_UP}
{$ENDIF}

{$IFDEF DELPHI5}
  {$DEFINE DELPHI1_UP}
  {$DEFINE DELPHI2_UP}
  {$DEFINE DELPHI3_UP}
  {$DEFINE DELPHI4_UP}
  {$DEFINE DELPHI5_UP}
{$ENDIF}

{$IFDEF DELPHI6}
  {$DEFINE DELPHI1_UP}
  {$DEFINE DELPHI2_UP}
  {$DEFINE DELPHI3_UP}
  {$DEFINE DELPHI4_UP}
  {$DEFINE DELPHI5_UP}
  {$DEFINE DELPHI6_UP}
{$ENDIF}

{$IFDEF DELPHI7}
  {$DEFINE DELPHI1_UP}
  {$DEFINE DELPHI2_UP}
  {$DEFINE DELPHI3_UP}
  {$DEFINE DELPHI4_UP}
  {$DEFINE DELPHI5_UP}
  {$DEFINE DELPHI6_UP}
  {$DEFINE DELPHI7_UP}
{$ENDIF}

// BCBx_UP
{$IFDEF BCB1}
  {$DEFINE BCB1_UP}
{$ENDIF}

{$IFDEF BCB3}
  {$DEFINE BCB1_UP}
  {$DEFINE BCB3_UP}
{$ENDIF}

{$IFDEF BCB4}
  {$DEFINE BCB1_UP}
  {$DEFINE BCB3_UP}
  {$DEFINE BCB4_UP}
{$ENDIF}

{$IFDEF BCB5}
  {$DEFINE BCB1_UP}
  {$DEFINE BCB3_UP}
  {$DEFINE BCB4_UP}
  {$DEFINE BCB5_UP}
{$ENDIF}

{$IFDEF BCB3_UP}
  {$ObjExportAll On}
  {$DEFINE TLIST_CLEAR_VIRTUAL}
{$ENDIF}

{$IFDEF DELPHI4_UP}
  {$DEFINE TLIST_CLEAR_VIRTUAL}
{$ENDIF}

// コンパイラ指令
{$V+,B-,X+,T-,P+,H+,J+}

