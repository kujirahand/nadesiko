/*
なでしこで利用する型の定義
*/
#ifndef	dnako_import_types_h__
#define	dnako_import_types_h__

#include <windows.h>
#include <iostream>

using namespace std;

typedef char* PAnsiChar;
typedef char* PAnsiString;
typedef unsigned long HFloat,*PHFloat;

typedef enum __THiVType{varNil = 0, varInt=1, varFloat=2, varStr=3, varPointer=4,
    varFunc=5, varArray=6, varHash=7, varGroup=8, varLink=9}THiVType;

#pragma pack(push,1)
typedef struct tagTHiValue{
    BYTE		VType; // 値の型
    int			Size;  // 値の大きさ
    DWORD		VarID;    // 変数名
    int			RefCount;  // 参照カウント for GC
    struct tagTHiValue	*Setter; // Setter
    struct tagTHiValue	*Getter; // Getter
    BYTE		ReadOnly;     // ReadOnly = 1
    BYTE		Registered;   // 解放してよい値か？(これが1なら勝手に解放してはならない)
    BYTE		Flag1;
    BYTE		Flag2;
    union {//case Byte of
    int integer; // varInt
    void *ptr; // other...
    char *ptr_s; // varStr
	};
} THiValue;
#pragma pack(pop)
typedef THiValue *PHiValue;

typedef PHiValue(__stdcall *THimaSysFunction)(DWORD);
typedef double	Double;
typedef double	Extended; // todo: 正しくないがとりあえず適当

extern PHiValue hi_var_new(string name/*= ""*/);
// 新規変数を生成する
extern PHiValue hi_clone(PHiValue v); // 関数とまったく同じものを生成する
extern PHiValue hi_newInt(int value); // 新規整数
extern PHiValue hi_newStr(string value);  // 新規文字列
extern PHiValue hi_newFloat(HFloat value);// 新規文字列
// 整数をセットする
extern void hi_setInt  (PHiValue v,int num);
extern void hi_setFloat(PHiValue v,HFloat num);
// BOOL型をセットする
extern void hi_setBool(PHiValue v,BOOL b);
// 文字列をセットする
extern void hi_setStr(PHiValue v,std::string s);
// キャストして使えるように
extern BOOL hi_bool(PHiValue value);
extern int hi_int  (PHiValue value);
extern double hi_float(PHiValue value);
extern string hi_str(PHiValue p);

#endif //dnako_import_types_h__

