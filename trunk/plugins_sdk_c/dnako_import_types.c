/*
dnako.dllの関数を間接的に使う関数の定義
*/
#include <windows.h>
#include "dnako_import_types.h"
#include "dnako_import.h"

PHiValue hi_var_new(char* name);
// 新規変数を生成する
PHiValue hi_clone(PHiValue v); // 関数とまったく同じものを生成する
PHiValue hi_newInt(int value); // 新規整数
PHiValue hi_newStr(char* value);  // 新規文字列
PHiValue hi_newFloat(HFloat value);// 新規文字列
// 整数をセットする
void hi_setInt  (PHiValue v,int num);
void hi_setFloat(PHiValue v,HFloat num);
// BOOL型をセットする
void hi_setBool(PHiValue v,BOOL b);
// 文字列をセットする
void hi_setStr(PHiValue v,char* s, int len);
// キャストして使えるように
BOOL hi_bool(PHiValue value);
int hi_int  (PHiValue value);
double hi_float(PHiValue value);
char* hi_str(PHiValue p);


PHiValue hi_var_new(char* name){// 新規変数を生成する
	return nako_var_new(name);
}
PHiValue hi_clone(PHiValue v){ // 関数とまったく同じものを生成する
	PHiValue Result = hi_var_new(NULL);
	nako_varCopyGensi(v, Result);
	return Result;
}
PHiValue hi_newInt(int value){ // 新規整数
	PHiValue Result = hi_var_new(NULL);
	hi_setInt(Result, value);
	return Result;
}
PHiValue hi_newStr(char* value){  // 新規文字列
	PHiValue Result = hi_var_new(NULL);
	hi_setStr(Result, value, strlen(value));
	return Result;
}
PHiValue hi_newFloat(HFloat value){// 新規文字列
	PHiValue Result = hi_var_new(NULL);
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
void hi_setStr(PHiValue v,char* s, int len){
	nako_bin2var(s, len, v);
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
char* hi_str(PHiValue p){
	return p->ptr_s;
}


