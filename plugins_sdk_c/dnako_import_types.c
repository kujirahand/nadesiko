/*
dnako.dll�̊֐����ԐړI�Ɏg���֐��̒�`
*/
#include <windows.h>
#include "dnako_import_types.h"
#include "dnako_import.h"

PHiValue hi_var_new(char* name);
// �V�K�ϐ��𐶐�����
PHiValue hi_clone(PHiValue v); // �֐��Ƃ܂������������̂𐶐�����
PHiValue hi_newInt(int value); // �V�K����
PHiValue hi_newStr(char* value);  // �V�K������
PHiValue hi_newFloat(HFloat value);// �V�K������
// �������Z�b�g����
void hi_setInt  (PHiValue v,int num);
void hi_setFloat(PHiValue v,HFloat num);
// BOOL�^���Z�b�g����
void hi_setBool(PHiValue v,BOOL b);
// ��������Z�b�g����
void hi_setStr(PHiValue v,char* s, int len);
// �L���X�g���Ďg����悤��
BOOL hi_bool(PHiValue value);
int hi_int  (PHiValue value);
double hi_float(PHiValue value);
char* hi_str(PHiValue p);


PHiValue hi_var_new(char* name){// �V�K�ϐ��𐶐�����
	return nako_var_new(name);
}
PHiValue hi_clone(PHiValue v){ // �֐��Ƃ܂������������̂𐶐�����
	PHiValue Result = hi_var_new(NULL);
	nako_varCopyGensi(v, Result);
	return Result;
}
PHiValue hi_newInt(int value){ // �V�K����
	PHiValue Result = hi_var_new(NULL);
	hi_setInt(Result, value);
	return Result;
}
PHiValue hi_newStr(char* value){  // �V�K������
	PHiValue Result = hi_var_new(NULL);
	hi_setStr(Result, value, strlen(value));
	return Result;
}
PHiValue hi_newFloat(HFloat value){// �V�K������
	PHiValue Result = hi_var_new(NULL);
	hi_setFloat(Result, value);
	return Result;
}
// �������Z�b�g����
void hi_setInt  (PHiValue v,int num){
	nako_int2var(num, v);
}
void hi_setFloat(PHiValue v,HFloat num){
	nako_double2var(num, v);
}
// BOOL�^���Z�b�g����
void hi_setBool(PHiValue v,BOOL b){
	if(b)
		nako_int2var(1, v);
	else
		nako_int2var(0, v);
}
// ��������Z�b�g����
void hi_setStr(PHiValue v,char* s, int len){
	nako_bin2var(s, len, v);
}
// �L���X�g���Ďg����悤��
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


