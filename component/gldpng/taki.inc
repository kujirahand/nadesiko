//********************************************
//    コンパイル指令＆バージョンチェック
//                           2001.07.04 改変
//********************************************

//---------------------------------------------------------
// コンパイラオプション設定
//---------------------------------------------------------

{$EXTENDEDSYNTAX ON}
{$LONGSTRINGS ON}
{$OPTIMIZATION ON}
{$WARNINGS OFF}
{$HINTS OFF}
{$BOOLEVAL OFF}
{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}


//---------------------------------------------------------
// コンパイラ情報
//
// VER80  Delphi1
// VER90  Delphi2
// VER93  C++Builder1
// VER100 Delphi3
// VER110 C++Builder3
// VER120 Delphi4
// VER130 Delphi5
//---------------------------------------------------------

// コンパイラの種類チェック1
{$IFDEF VER80}
 Delphi1では使えません。
 これを消しても暴走するだけです。
 無駄なことはしないでDelphi3(C++Builder3)以上で使ってください。
{$ENDIF}

{$IFDEF VER90}
  {$DEFINE DEL2}
{$ELSE}
 {$IFDEF VER93}
   {$DEFINE DEL2}
 {$ELSE}
  {$IFDEF VER100}
    {$DEFINE DEL3}
  {$ELSE}
   {$IFDEF VER110}
     {$DEFINE DEL3}
   {$ELSE}
     {$DEFINE DEL4}
   {$ENDIF}
  {$ENDIF}
 {$ENDIF}
{$ENDIF}

{$IFDEF VER110}
 {$DEFINE BCB3}
{$ENDIF}

// コンパイラの種類チェック2
{$IFDEF DEL2}
 Delphi2またはC++builder1では使えません。
 これを消しても暴走するだけです。
 無駄なことはしないでDelphi3(C++builder3)以上で使ってください。
{$ENDIF}

{$IFDEF DEL4}
 // Delphi4以降の追加処理用
 {$DEFINE SUPPORT_D4}
{$ENDIF}

{$IFNDEF DEL2}
 {$ObjExportAll ON}  // C++Builder3以上ではこれいれないとだめなようだ。
{$ENDIF}


