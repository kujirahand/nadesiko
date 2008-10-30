/*
dnako.dllの関数を間接的に使う関数の定義
*/
#include <windows.h>
#include <iostream>
#include "dnako_import_types.h"
#include "dnako_import.h"

using namespace std;

PHiValue hi_var_new(string name);
// 新規変数を生成する
PHiValue hi_clone(PHiValue v); // 関数とまったく同じものを生成する
PHiValue hi_newInt(int value); // 新規整数
PHiValue hi_newStr(string value);  // 新規文字列
PHiValue hi_newFloat(HFloat value);// 新規文字列
// 整数をセットする
void hi_setInt  (PHiValue v,int num);
void hi_setFloat(PHiValue v,HFloat num);
// BOOL型をセットする
void hi_setBool(PHiValue v,BOOL b);
// 文字列をセットする
void hi_setStr(PHiValue v,string s);
// キャストして使えるように
BOOL hi_bool(PHiValue value);
int hi_int  (PHiValue value);
double hi_float(PHiValue value);
string hi_str(PHiValue p);


PHiValue hi_var_new(string name= ""){// 新規変数を生成する
	if (name.empty()) 
		return nako_var_new(NULL);
	else
		return nako_var_new(const_cast<char *>(name.c_str()));
}
PHiValue hi_clone(PHiValue v){ // 関数とまったく同じものを生成する
	PHiValue Result = hi_var_new();
	nako_varCopyGensi(v, Result);
	return Result;
}
PHiValue hi_newInt(int value){ // 新規整数
	PHiValue Result = hi_var_new();
	hi_setInt(Result, value);
	return Result;
}
PHiValue hi_newStr(string value){  // 新規文字列
	PHiValue Result = hi_var_new();
	hi_setStr(Result, value);
	return Result;
}
PHiValue hi_newFloat(HFloat value){// 新規文字列
	PHiValue Result = hi_var_new();
	hi_setFloat(Result, value);
	return Result;
}
// 整数をセットする
void hi_setInt  (PHiValue v,int num){
	nako_int2var(num, v);
}
void hi_setFloat(PHiValue v,HFloat num){
	nako_double2var(num, v);
}
// BOOL型をセットする
void hi_setBool(PHiValue v,BOOL b){
	if(b)
		nako_int2var(1, v);
	else
		nako_int2var(0, v);
}
// 文字列をセットする
void hi_setStr(PHiValue v,string s){
	if (s.empty())
		nako_str2var(const_cast<char *>(s.c_str()), v);
	else
		nako_bin2var(const_cast<char *>(s.c_str())/*&s[0]*/, s.length(), v);
}
// キャストして使えるように
BOOL hi_bool(PHiValue value){
	return (nako_var2int(value) != 0);
}
int hi_int  (PHiValue value){
	return nako_var2int(value);
}
double hi_float(PHiValue value){
	return nako_var2double(value);
}
string hi_str(PHiValue p){
	const int MAX_STR = 255;
	DWORD len;
	string Result;
	if(p == NULL){
		return "";
	}	
	// 適当に確保して文字列をコピー
	Result.resize(MAX_STR+1);
	len = nako_var2str(p,const_cast<char *>(Result.c_str())/*&Result[1]*/, MAX_STR);
	
	if (len > MAX_STR){
	  Result.resize(len);
	  nako_var2str(p, const_cast<char *>(Result.c_str())/*&Result[1]*/, len);
	} else{
	  Result.resize(len); // リサイズ
	  /*if (len == 0) {
		return 0;
	  }*/
	}
	return Result;
}
