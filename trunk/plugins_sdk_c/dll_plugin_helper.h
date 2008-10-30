/*
プラグインを作るうえで便利な命令を定義
*/
#ifndef	__HELPER__
#define	__HELPER__
#include<windows.h>
#include<iostream>

#include "dnako_import_types.h"

using namespace std;

// 関数が正しく登録できるかチェックする
extern void _checkTag(DWORD tag,DWORD name);
// 関数を登録する
extern void AddFunc(string name,string argStr,int tag,THimaSysFunction func,
  string kaisetu,string yomigana);
// 文字列を登録する
extern void AddStrVar(string name,string value,int tag,string kaisetu,
  string yomigana);
// 整数を登録する
extern void AddIntVar(string name,int value,int tag,string kaisetu,
  string yomigana);
// セッター・ゲッターをセットする
extern void SetSetterGetter(string name,string setter,string getter,
     DWORD tag,string desc,string yomi);

#endif /*__HELPER__*/
