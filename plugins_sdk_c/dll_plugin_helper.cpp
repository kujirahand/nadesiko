/*
プラグインを作るうえで便利な命令の実体
*/
#include <iostream>
//#include <stdlib.h>
#include <stdio.h>

#include	"dnako_import_types.h"
#include	"dnako_import.h"

using namespace std;

// 関数が正しく登録できるかチェックする
void _checkTag(DWORD tag,DWORD name);
// 関数を登録する
void AddFunc(string name,string argStr,int tag,THimaSysFunction func,
  string kaisetu,string yomigana);
// 文字列を登録する
void AddStrVar(string name,string value,int tag,string kaisetu,
  string yomigana);
// 整数を登録する
void AddIntVar(string name,int value,int tag,string kaisetu,
  string yomigana);
// セッター・ゲッターをセットする
void SetSetterGetter(string name,string setter,string getter,
     DWORD tag,string desc,string yomi);


void _checkTag(DWORD tag,DWORD name){
	nako_check_tag(tag, name);
}
void AddFunc(string name,string argStr,int tag,THimaSysFunction func,
  string kaisetu,string yomigana){
	try{
		_checkTag(tag, 0);
	}catch(...){
		/*注意　エラー処理は暫定です*/
		//RAISE(Exception.Create('『'+name+'』(tag='+IntToStr(tag)+')が重複しています。');
		/*char tag_c[6];
		itoa(tag,tag_c,10);
		throw domain_error(("『"+name+"』(tag="+tag_c+")が重複しています。").c_str());*/
		char mes[50];
		sprintf(mes,"『%s』(tag=%d)が重複しています。",name.c_str(),tag);
		throw domain_error(mes);
	}
	nako_addFunction(const_cast<char *>(name.c_str()),
	   const_cast<char *>(argStr.c_str()),func, tag);
}
// 文字列を登録する
void AddStrVar(string name,string value,int tag,string kaisetu,
  string yomigana){
	_checkTag(tag, 0);
	nako_addStrVar(const_cast<char *>(name.c_str()), const_cast<char *>(value.c_str()), tag);
}
// 整数を登録する
void AddIntVar(string name,int value,int tag,string kaisetu,
  string yomigana){
	_checkTag(tag, 0);
	nako_addIntVar(const_cast<char *>(name.c_str()), value, tag);
}
// セッター・ゲッターをセットする
void SetSetterGetter(string name,string setter,string getter,
     DWORD tag,string desc,string yomi){
	 nako_addSetterGetter(const_cast<char *>(name.c_str()), const_cast<char *>(setter.c_str()),
	  const_cast<char *>(getter.c_str()), tag);
}

